<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\MenuController;
use App\Http\Controllers\Api\PriceHistoryController;
use App\Http\Controllers\Api\PromoController;
use App\Http\Controllers\Api\TransactionController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// Modul 1: Menu Management
Route::apiResource('menus', MenuController::class);

// Modul 2: Price Management
Route::get('menus/{menu}/prices', [PriceHistoryController::class, 'index']);
Route::post('menus/{menu}/prices', [PriceHistoryController::class, 'store']);

// Modul 3: Promo Management
Route::apiResource('promos', PromoController::class);

// Modul 4: Transactions (POS)
Route::post('transactions/calculate', [TransactionController::class, 'calculate']);
Route::post('transactions', [TransactionController::class, 'store']);
Route::get('transactions/{invoice_number}', [TransactionController::class, 'show']);