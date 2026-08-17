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

        // Calculate COGS/Modal from items
        $transactionIds = $transactions->pluck('id');
        
        $items = TransactionItem::with('menu')->whereIn('transaction_id', $transactionIds)->get();
        
        $totalCogs = 0;
        $salesByMenuRaw = [];

        foreach ($items as $item) {
            $itemCogs = $item->qty * $item->modal_saat_ini;
            $totalCogs += $itemCogs;
            
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
            $salesByMenuRaw[$item->menu_id]['cogs'] += $itemCogs;
        }

        $grossProfit = $netRevenue - $totalCogs;
        
        // Convert to indexed array and sort by qty_sold descending
        $salesByMenu = array_values($salesByMenuRaw);
        usort($salesByMenu, function ($a, $b) {
            return $b['qty_sold'] <=> $a['qty_sold'];
        });

        // Promo Analytics
        $promoAnalyticsRaw = Transaction::with('promo')
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
            $promoAnalyticsAssoc[$tx->promo_id]['times_used'] += 1;
            $promoAnalyticsAssoc[$tx->promo_id]['total_discount_given'] += $tx->discount_amount;
        }
        $promoAnalytics = array_values($promoAnalyticsAssoc);

        // Sales by Kasir
        $salesByKasir = Transaction::with('user:id,name,username')
            ->select('user_id', DB::raw('count(*) as total_transactions'), DB::raw('sum(total_amount) as total_revenue'))
            ->whereBetween('created_at', [$startDate . ' 00:00:00', $endDate . ' 23:59:59'])
            ->groupBy('user_id')
            ->get();

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
                    'gross_profit' => $grossProfit,
                ],
                'sales_by_menu' => $salesByMenu,
                'promo_analytics' => $promoAnalytics,
                'sales_by_kasir' => $salesByKasir,
            ]
        ]);
    }
}
