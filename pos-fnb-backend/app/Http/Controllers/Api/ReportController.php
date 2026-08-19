<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\TransactionItem;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class ReportController extends Controller
{
    public function salesSummary(Request $request): JsonResponse
    {
        $startDate = $request->query('start_date', Carbon::today()->toDateString());
        $endDate = $request->query('end_date', Carbon::today()->toDateString());

        // Basic summary
        $transactions = Transaction::whereBetween('created_at', [$startDate . ' 00:00:00', $endDate . ' 23:59:59'])->get();
        
        $grossRevenue = $transactions->sum('subtotal');
        $totalDiscount = $transactions->sum('discount_amount');
        $netRevenue = $transactions->sum('total_amount');
        $totalTransactions = $transactions->count();

        // Calculate COGS/Modal from transaction items (untuk analisis per menu)
        $transactionIds = $transactions->pluck('id');
        
        $items = TransactionItem::with('menu')->whereIn('transaction_id', $transactionIds)->get();
        
        $salesByMenuRaw = [];

        foreach ($items as $item) {
            // Menu Analytics logic
            if (!isset($salesByMenuRaw[$item->menu_id])) {
                $salesByMenuRaw[$item->menu_id] = [
                    'menu_id' => $item->menu_id,
                    'menu_name' => $item->menu ? $item->menu->nama_menu : 'Unknown',
                    'qty_sold' => 0,
                    'gross_revenue' => 0,
                    'cogs' => 0,
                ];
            }
            $salesByMenuRaw[$item->menu_id]['qty_sold'] += $item->qty;
            $salesByMenuRaw[$item->menu_id]['gross_revenue'] += $item->subtotal;
            if (!$item->is_free) {
                $salesByMenuRaw[$item->menu_id]['cogs'] += $item->modal_saat_ini;
            }
        }

        // Total Modal (COGS/HPP) = total harga modal dari barang yang TERJUAL NORMAL pada transaksi di periode tersebut
        $totalCogs = $items->where('is_free', false)->sum('modal_saat_ini');

        // Biaya Promo (Promo Expense) = total harga modal dari barang GRATIS (BOGO)
        $promoExpense = $items->where('is_free', true)->sum('modal_saat_ini');

        // Laba Kotor (Gross Profit) = Pendapatan Bersih (Net Revenue) - Harga Pokok Penjualan (COGS)
        $grossProfit = $netRevenue - $totalCogs;

        // Total Kekayaan Persediaan (Inventory Asset) = total modal stok barang yang masih BELUM terjual
        $totalInventoryAsset = \App\Models\InventoryBatch::where('qty_remaining', '>', 0)
            ->get()
            ->sum(function ($batch) {
                return $batch->qty_remaining * $batch->modal;
            });
        
        // Convert to indexed array and sort by qty_sold descending
        $salesByMenu = array_values($salesByMenuRaw);
        usort($salesByMenu, function ($a, $b) {
            return $b['qty_sold'] <=> $a['qty_sold'];
        });

        // Promo Analytics
        $promoAnalyticsRaw = Transaction::with(['promo', 'items.menu'])
            ->whereNotNull('promo_id')
            ->whereBetween('created_at', [$startDate . ' 00:00:00', $endDate . ' 23:59:59'])
            ->get();
            
        $promoAnalyticsAssoc = [];
        foreach ($promoAnalyticsRaw as $tx) {
            if (!isset($promoAnalyticsAssoc[$tx->promo_id])) {
                $promoAnalyticsAssoc[$tx->promo_id] = [
                    'promo_id' => $tx->promo_id,
                    'promo_name' => $tx->promo ? $tx->promo->name : 'Unknown',
                    'times_used' => 0,
                    'total_discount_given' => 0,
                ];
            }
            
            $discountGiven = (float) $tx->discount_amount;
            
            if ($tx->promo && $tx->promo->type === 'bogo') {
                foreach ($tx->items as $item) {
                    if ($item->is_free && $item->menu) {
                        $discountGiven += ($item->qty * $item->menu->price);
                    }
                }
            }
            
            $promoAnalyticsAssoc[$tx->promo_id]['times_used'] += 1;
            $promoAnalyticsAssoc[$tx->promo_id]['total_discount_given'] += $discountGiven;
        }
        $promoAnalytics = array_values($promoAnalyticsAssoc);

        // Sales by Kasir
        $salesByKasir = Transaction::with('user:id,name,username')
            ->select('user_id', DB::raw('count(*) as total_transactions'), DB::raw('sum(total_amount) as total_revenue'))
            ->whereBetween('created_at', [$startDate . ' 00:00:00', $endDate . ' 23:59:59'])
            ->groupBy('user_id')
            ->get();

        // Format Invoices for frontend
        $invoices = Transaction::with('user:id,name,username')
            ->whereBetween('created_at', [$startDate . ' 00:00:00', $endDate . ' 23:59:59'])
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($tx) {
                return [
                    'invoice_number' => $tx->invoice_number,
                    'total_amount' => $tx->total_amount,
                    'created_at' => $tx->created_at,
                    'kasir_name' => $tx->user ? $tx->user->name : 'Unknown',
                ];
            });

        return response()->json([
            'data' => [
                'period' => [
                    'start' => $startDate,
                    'end' => $endDate,
                ],
                'summary' => [
                    'total_transactions' => $totalTransactions,
                    'gross_revenue' => $grossRevenue,
                    'total_discount' => $totalDiscount,
                    'net_revenue' => $netRevenue,
                    'total_cogs' => $totalCogs,
                    'promo_expense' => $promoExpense,
                    'gross_profit' => $grossProfit,
                    'total_inventory_asset' => $totalInventoryAsset,
                ],
                'sales_by_menu' => $salesByMenu,
                'promo_analytics' => $promoAnalytics,
                'sales_by_kasir' => $salesByKasir,
                'invoices' => $invoices,
            ]
        ]);
    }
}
