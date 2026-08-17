<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Menu;
use App\Models\PriceHistory;
use App\Http\Requests\StoreMenuRequest;
use App\Http\Requests\UpdateMenuRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
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

            // Auto-generate kode_menu
            $kategori = strtolower($menuData['kategori']);
            $prefix = 'ot';
            if ($kategori === 'makanan' || $kategori === 'mk') $prefix = 'mk';
            elseif ($kategori === 'minuman' || $kategori === 'mn') $prefix = 'mn';
            elseif ($kategori === 'desert' || $kategori === 'dessert' || $kategori === 'ds') $prefix = 'ds';
            elseif ($kategori === 'coffee' || $kategori === 'kopi' || $kategori === 'cf') $prefix = 'cf';

            $lastMenu = Menu::where('kode_menu', 'like', $prefix . '%')
                ->orderByRaw('LENGTH(kode_menu) DESC')
                ->orderBy('kode_menu', 'desc')
                ->first();

            $nextIndex = 1;
            if ($lastMenu) {
                $lastCode = $lastMenu->kode_menu;
                $lastIndex = (int) str_replace($prefix, '', $lastCode);
                $nextIndex = $lastIndex + 1;
            }
            $menuData['kode_menu'] = $prefix . $nextIndex;

            // Hapus blok file upload karena gambar sekarang hanya URL teks biasa

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
        $menuData = $request->validated();

        // Hapus blok file upload dan delete old image karena sekarang hanya URL teks biasa

        $menu->update($menuData);

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