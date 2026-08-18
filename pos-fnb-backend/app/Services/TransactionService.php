<?php

namespace App\Services;

use App\Models\Transaction;
use App\Models\TransactionItem;
use App\Models\Promo;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Exception;

class TransactionService
{
    protected $promoCalculationService;

    public function __construct(PromoCalculationService $promoCalculationService)
    {
        $this->promoCalculationService = $promoCalculationService;
    }

    public function calculatePreview(array $items, $promoId = null)
    {
        $promo = $promoId ? Promo::find($promoId) : null;
        return $this->promoCalculationService->calculate($items, $promo);
    }

    /**
     * Generate a unique invoice number with retry logic.
     * Format: INV-YYYYMMDD-XXXXXX (6-char random alphanumeric)
     */
    private function generateInvoiceNumber(): string
    {
        $maxRetries = 5;
        for ($i = 0; $i < $maxRetries; $i++) {
            $invoiceNumber = 'INV-' . date('Ymd') . '-' . strtoupper(Str::random(6));
            $exists = Transaction::where('invoice_number', $invoiceNumber)->exists();
            if (!$exists) {
                return $invoiceNumber;
            }
        }
        // Fallback: use full timestamp + longer random to virtually guarantee uniqueness
        return 'INV-' . date('YmdHis') . '-' . strtoupper(Str::random(8));
    }

    public function checkout(array $items, $paymentAmount, $promoId = null, $userId = null, $paymentMethod = 'Cash')
    {
        return DB::transaction(function () use ($items, $paymentAmount, $promoId, $userId, $paymentMethod) {
            // Lock promo row early to prevent concurrent quota issues
            $promo = null;
            if ($promoId) {
                $promo = Promo::lockForUpdate()->find($promoId);
                if (!$promo) {
                    throw new Exception('Promo tidak ditemukan.');
                }
                // Re-validate quota inside the lock
                if ($promo->quota !== null && $promo->quota <= 0) {
                    throw new Exception('Kuota promo ini sudah habis.');
                }
            }

            $calculation = $this->promoCalculationService->calculate($items, $promo);

            if ($paymentAmount < $calculation['total_amount']) {
                throw new Exception('Payment amount is less than the total amount.');
            }

            $changeAmount = $paymentAmount - $calculation['total_amount'];
            
            // Generate unique invoice number with retry
            $invoiceNumber = $this->generateInvoiceNumber();

            $transaction = Transaction::create([
                'invoice_number' => $invoiceNumber,
                'subtotal' => $calculation['subtotal'],
                'discount_amount' => $calculation['discount_amount'],
                'total_amount' => $calculation['total_amount'],
                'payment_amount' => $paymentAmount,
                'change_amount' => $changeAmount,
                'promo_id' => $calculation['promo_id'],
                'user_id' => $userId,
                'payment_method' => $paymentMethod,
            ]);

            foreach ($calculation['items'] as $itemData) {
                $qtyNeeded = $itemData['qty'];
                $totalCogs = 0;
                
                $batches = \App\Models\InventoryBatch::where('menu_id', $itemData['menu_id'])
                    ->where('qty_remaining', '>', 0)
                    ->orderBy('purchased_at', 'asc')
                    ->orderBy('id', 'asc')
                    ->lockForUpdate()
                    ->get();
                    
                $remainingToFulfill = $qtyNeeded;
                
                foreach ($batches as $batch) {
                    if ($remainingToFulfill <= 0) break;
                    
                    $take = min($batch->qty_remaining, $remainingToFulfill);
                    $totalCogs += $take * $batch->modal;
                    
                    $batch->qty_remaining -= $take;
                    $batch->save();
                    
                    $remainingToFulfill -= $take;
                }
                
                if ($remainingToFulfill > 0) {
                    $menuName = \App\Models\Menu::find($itemData['menu_id'])->nama_menu ?? 'Unknown Menu';
                    throw new Exception("Stok menu {$menuName} tidak mencukupi. Kurang {$remainingToFulfill} porsi.");
                }

                TransactionItem::create([
                    'transaction_id' => $transaction->id,
                    'menu_id' => $itemData['menu_id'],
                    'qty' => $itemData['qty'],
                    'price' => $itemData['price'],
                    'subtotal' => $itemData['subtotal'],
                    'modal_saat_ini' => $totalCogs, // Storing TOTAL COGS for this item based on FIFO
                ]);
            }

            // Atomic quota decrement with safety check (prevents negative)
            if ($promo && $promo->quota !== null) {
                $affected = Promo::where('id', $promo->id)
                    ->where('quota', '>', 0)
                    ->decrement('quota');
                if ($affected === 0) {
                    throw new Exception('Kuota promo ini sudah habis (concurrent checkout).');
                }
            }
            if ($promo) {
                $promo->increment('used_quota');
            }

            return $transaction->load('items.menu', 'promo', 'user');
        });
    }
}
