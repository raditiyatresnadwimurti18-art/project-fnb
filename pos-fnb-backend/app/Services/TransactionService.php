<?php

namespace App\Services;

use App\Models\Transaction;
use App\Models\TransactionItem;
use App\Models\Promo;
use Illuminate\Support\Facades\DB;
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

    public function checkout(array $items, $paymentAmount, $promoId = null, $userId = null)
    {
        return DB::transaction(function () use ($items, $paymentAmount, $promoId, $userId) {
            $promo = $promoId ? Promo::find($promoId) : null;
            $calculation = $this->promoCalculationService->calculate($items, $promo);

            if ($paymentAmount < $calculation['total_amount']) {
                throw new Exception('Payment amount is less than the total amount.');
            }

            $changeAmount = $paymentAmount - $calculation['total_amount'];
            
            // Generate unique invoice number: INV-YYYYMMDDHHMMSS-RAND
            $invoiceNumber = 'INV-' . date('YmdHis') . '-' . rand(1000, 9999);

            $transaction = Transaction::create([
                'invoice_number' => $invoiceNumber,
                'subtotal' => $calculation['subtotal'],
                'discount_amount' => $calculation['discount_amount'],
                'total_amount' => $calculation['total_amount'],
                'payment_amount' => $paymentAmount,
                'change_amount' => $changeAmount,
                'promo_id' => $calculation['promo_id'],
                'user_id' => $userId,
            ]);

            foreach ($calculation['items'] as $itemData) {
                TransactionItem::create([
                    'transaction_id' => $transaction->id,
                    'menu_id' => $itemData['menu_id'],
                    'qty' => $itemData['qty'],
                    'price' => $itemData['price'],
                    'subtotal' => $itemData['subtotal'],
                ]);
            }

            if ($promo) {
                $promo->increment('used_quota');
            }

            return $transaction->load('items.menu', 'promo', 'user');
        });
    }
}
