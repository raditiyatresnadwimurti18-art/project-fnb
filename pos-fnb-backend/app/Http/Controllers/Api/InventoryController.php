<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

use App\Http\Requests\StoreInventoryBatchRequest;
use App\Models\InventoryBatch;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;

class InventoryController extends Controller
{
    /**
     * GET /inventory
     * Lihat semua batch inventory, bisa filter per menu_id.
     */
    public function index(Request $request): JsonResponse
    {
        $query = InventoryBatch::with('menu:id,nama_menu,kategori,price')
            ->orderBy('purchased_at', 'desc')
            ->orderBy('id', 'desc');

        if ($request->has('menu_id')) {
            $query->where('menu_id', $request->input('menu_id'));
        }

        // Filter: hanya batch yang masih punya sisa stok
        if ($request->boolean('active_only', false)) {
            $query->where('qty_remaining', '>', 0);
        }

        $batches = $query->get();

        // Hitung summary per menu
        $summary = $batches->groupBy('menu_id')->map(function ($menuBatches) {
            $totalRemaining = $menuBatches->sum('qty_remaining');
            $totalPurchased = $menuBatches->sum('qty_purchased');

            // Weighted average modal (berdasarkan sisa stok)
            $activeBatches = $menuBatches->where('qty_remaining', '>', 0);
            $weightedModal = $activeBatches->sum(function ($b) {
                return $b->modal * $b->qty_remaining;
            });
            $avgModal = $totalRemaining > 0 ? round($weightedModal / $totalRemaining, 2) : 0;

            return [
                'menu_id' => $menuBatches->first()->menu_id,
                'menu' => $menuBatches->first()->menu,
                'total_purchased' => $totalPurchased,
                'total_remaining' => $totalRemaining,
                'avg_modal' => $avgModal,
                'batch_count' => $menuBatches->count(),
                'active_batch_count' => $activeBatches->count(),
            ];
        })->values();

        return response()->json([
            'message' => 'Inventory batches retrieved successfully',
            'summary' => $summary,
            'batches' => $batches,
        ]);
    }

    /**
     * GET /inventory/{menuId}
     * Lihat batch inventory untuk menu tertentu.
     */
    public function show(int $menuId): JsonResponse
    {
        $menu = \App\Models\Menu::findOrFail($menuId);

        $batches = InventoryBatch::where('menu_id', $menuId)
            ->orderBy('purchased_at', 'desc')
            ->orderBy('id', 'desc')
            ->get();

        $activeBatches = $batches->where('qty_remaining', '>', 0);
        $totalRemaining = $batches->sum('qty_remaining');
        $totalPurchased = $batches->sum('qty_purchased');

        // Weighted average modal berdasarkan sisa stok
        $weightedModal = $activeBatches->sum(function ($b) {
            return $b->modal * $b->qty_remaining;
        });
        $avgModal = $totalRemaining > 0 ? round($weightedModal / $totalRemaining, 2) : 0;

        return response()->json([
            'message' => 'Inventory detail retrieved successfully',
            'data' => [
                'menu' => $menu,
                'total_purchased' => $totalPurchased,
                'total_remaining' => $totalRemaining,
                'avg_modal' => $avgModal,
                'batch_count' => $batches->count(),
                'active_batch_count' => $activeBatches->count(),
                'batches' => $batches,
            ],
        ]);
    }

    public function store(StoreInventoryBatchRequest $request): JsonResponse
    {
        $data = $request->validated();
        
        $batch = InventoryBatch::create([
            'menu_id' => $data['menu_id'],
            'qty_purchased' => $data['qty'],
            'qty_remaining' => $data['qty'],
            'modal' => $data['modal'],
            'purchased_at' => Carbon::now(),
        ]);

        return response()->json([
            'message' => 'Stock added successfully',
            'data' => $batch
        ], 201);
    }

    public function adjust(Request $request): JsonResponse
    {
        $request->validate([
            'menu_id' => 'required|exists:menus,id',
            'qty' => 'required|integer|min:1',
        ]);

        try {
            \Illuminate\Support\Facades\DB::transaction(function () use ($request) {
                $qtyNeeded = $request->input('qty');
                $menuId = $request->input('menu_id');
                
                // Check total available stock first before modifying anything
                $totalAvailable = InventoryBatch::where('menu_id', $menuId)
                    ->where('qty_remaining', '>', 0)
                    ->lockForUpdate()
                    ->sum('qty_remaining');

                if ($totalAvailable < $qtyNeeded) {
                    throw new \Exception("Stok total tidak mencukupi untuk dikurangi. Tersedia: {$totalAvailable}, dibutuhkan: {$qtyNeeded}.");
                }

                $batches = InventoryBatch::where('menu_id', $menuId)
                    ->where('qty_remaining', '>', 0)
                    ->orderBy('purchased_at', 'asc')
                    ->orderBy('id', 'asc')
                    ->lockForUpdate()
                    ->get();
                    
                $remainingToFulfill = $qtyNeeded;
                
                foreach ($batches as $batch) {
                    if ($remainingToFulfill <= 0) break;
                    
                    $take = min($batch->qty_remaining, $remainingToFulfill);
                    
                    $batch->qty_remaining -= $take;
                    $batch->save();
                    
                    $remainingToFulfill -= $take;
                }
            });

            return response()->json([
                'message' => 'Stock adjusted successfully',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage(),
            ], 400);
        }
    }
}
