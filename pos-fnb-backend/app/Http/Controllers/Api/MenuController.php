<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Menu;
use App\Models\PriceHistory;
use App\Http\Requests\StoreMenuRequest;
use App\Http\Requests\UpdateMenuRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class MenuController extends Controller
{
    public function index(): JsonResponse
    {
        $menus = Menu::with('currentPrice')->get();
        return response()->json(['data' => $menus]);
    }

    public function store(StoreMenuRequest $request): JsonResponse
    {
        return DB::transaction(function () use ($request) {
            $menuData = $request->validated();
            $price = $menuData['price'];
            unset($menuData['price']);

            $menu = Menu::create($menuData);

            PriceHistory::create([
                'menu_id' => $menu->id,
                'old_price' => $price,
                'new_price' => $price,
                'effective_date' => Carbon::now(),
                // 'user_id' => auth()->id(), // Uncomment if using auth
            ]);

            return response()->json([
                'message' => 'Menu created successfully',
                'data' => $menu->load('currentPrice')
            ], 201);
        });
    }

    public function show($id): JsonResponse
    {
        $menu = Menu::with('currentPrice', 'priceHistories')->findOrFail($id);
        return response()->json(['data' => $menu]);
    }

    public function update(UpdateMenuRequest $request, $id): JsonResponse
    {
        $menu = Menu::findOrFail($id);
        $menu->update($request->validated());

        return response()->json([
            'message' => 'Menu updated successfully',
            'data' => $menu->load('currentPrice')
        ]);
    }

    public function destroy($id): JsonResponse
    {
        $menu = Menu::findOrFail($id);
        $menu->delete();

        return response()->json(['message' => 'Menu deleted successfully']);
    }
}