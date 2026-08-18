<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\MenuController;

use App\Http\Controllers\Api\PromoController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\KasirController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\InventoryController;




Route::post('/login', [AuthController::class, 'login']);
Route::get('/login', function () {
    return response()->json(['message' => 'Unauthenticated. Silakan login dan masukkan Token di tab Authorization.'], 401);
})->name('login');

// Public: Reference data
Route::get('/categories', function () {
    return response()->json([
        'data' => [
            ['id' => 'Makanan', 'name' => 'Makanan'],
            ['id' => 'Minuman', 'name' => 'Minuman'],
            ['id' => 'Desert', 'name' => 'Desert'],
            ['id' => 'Coffee', 'name' => 'Coffee'],
        ]
    ]);
});

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
    
    Route::post('/logout', [AuthController::class, 'logout']);
    
    // Modul Admin: Kasir Management
    Route::apiResource('kasir', KasirController::class);

    // Modul Laporan / Analisis
    Route::get('/reports/sales', [ReportController::class, 'salesSummary']);

    // Modul Inventory
    Route::get('/inventory', [InventoryController::class, 'index']);
    Route::get('/inventory/{menuId}', [InventoryController::class, 'show']);
    Route::post('/inventory/add-stock', [InventoryController::class, 'store']);
    Route::post('/inventory/adjust-stock', [InventoryController::class, 'adjust']);

    // Modul 1: Menu Management
    Route::apiResource('menus', MenuController::class);

    // Modul 3: Promo Management
    Route::apiResource('promos', PromoController::class);

    // Modul 4: Transactions (POS)
    Route::post('transactions/calculate', [TransactionController::class, 'calculate']);
    Route::post('transactions', [TransactionController::class, 'store']);
    Route::get('transactions/{invoice_number}', [TransactionController::class, 'show']);
});