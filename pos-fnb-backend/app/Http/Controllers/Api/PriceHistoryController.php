<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Menu;
use App\Models\PriceHistory;
use App\Http\Requests\StorePriceHistoryRequest;
use Illuminate\Http\JsonResponse;

class PriceHistoryController extends Controller
{
    public function index($menuId): JsonResponse
    {
        $menu = Menu::findOrFail($menuId);
        $histories = $menu->priceHistories()->orderBy('effective_date', 'desc')->get();
        
        return response()->json(['data' => $histories]);
    }

    public function store(StorePriceHistoryRequest $request, $menuId): JsonResponse
    {
        $menu = Menu::findOrFail($menuId);
        $data = $request->validated();
        
        $currentPrice = $menu->currentPrice ? $menu->currentPrice->new_price : 0;
        
        $data['menu_id'] = $menu->id;
        $data['old_price'] = $currentPrice;
        
        $priceHistory = PriceHistory::create($data);

        return response()->json([
            'message' => 'Price updated successfully',
            'data' => $priceHistory
        ], 201);
    }
}
