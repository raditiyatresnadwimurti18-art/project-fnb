<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\TransactionService;
use App\Http\Requests\CalculateTransactionRequest;
use App\Http\Requests\StoreTransactionRequest;
use App\Models\Transaction;
use Illuminate\Http\JsonResponse;

class TransactionController extends Controller
{
    protected $transactionService;

    public function __construct(TransactionService $transactionService)
    {
        $this->transactionService = $transactionService;
    }

    public function calculate(CalculateTransactionRequest $request): JsonResponse
    {
        $data = $request->validated();
        
        try {
            $preview = $this->transactionService->calculatePreview(
                $data['items'],
                $data['promo_id'] ?? null
            );

            return response()->json(['data' => $preview]);
        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], 400);
        }
    }

    public function store(StoreTransactionRequest $request): JsonResponse
    {
        $data = $request->validated();

        try {
            $userId = auth()->id() ?? $data['user_id'] ?? null;
            $paymentMethod = $data['payment_method'] ?? 'Cash';

            $transaction = $this->transactionService->checkout(
                $data['items'],
                $data['payment_amount'],
                $data['promo_id'] ?? null,
                $userId,
                $paymentMethod
            );

            return response()->json([
                'message' => 'Transaction successful',
                'data' => $transaction
            ], 201);
        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], 400);
        }
    }

    public function show($invoiceNumber): JsonResponse
    {
        $transaction = Transaction::with('items.menu', 'promo', 'user')
            ->where('invoice_number', $invoiceNumber)
            ->firstOrFail();

        return response()->json(['data' => $transaction]);
    }
}
