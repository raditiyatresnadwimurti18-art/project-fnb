<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Menu;
use App\Http\Requests\StoreMenuRequest;
use App\Http\Requests\UpdateMenuRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class MenuController extends Controller
{
    public function index(): JsonResponse
    {
        $menus = Menu::all();
        return response()->json(['data' => $menus]);
    }

    public function store(StoreMenuRequest $request): JsonResponse
    {
        return DB::transaction(function () use ($request) {
            $menuData = $request->validated();
            unset($menuData['is_active']); // Ignored if sent

            // Auto-generate kode_menu
            $kategori = strtolower($menuData['kategori']);
            $prefix = 'OTH-';
            if ($kategori === 'makanan' || $kategori === 'mk') $prefix = 'MKN-';
            elseif ($kategori === 'minuman' || $kategori === 'mn') $prefix = 'MNM-';
            elseif ($kategori === 'desert' || $kategori === 'dessert' || $kategori === 'ds') $prefix = 'DSS-';
            elseif ($kategori === 'coffee' || $kategori === 'kopi' || $kategori === 'cf') $prefix = 'COF-';

            $lastMenu = Menu::where('kode_menu', 'like', $prefix . '%')
                ->orderByRaw('LENGTH(kode_menu) DESC')
                ->orderBy('kode_menu', 'desc')
                ->lockForUpdate()
                ->first();

            $nextIndex = 1;
            if ($lastMenu) {
                $lastCode = $lastMenu->kode_menu;
                $lastIndex = (int) str_replace($prefix, '', $lastCode);
                $nextIndex = $lastIndex + 1;
            }
            $menuData['kode_menu'] = $prefix . str_pad($nextIndex, 3, '0', STR_PAD_LEFT);

            $menu = Menu::create($menuData);

            return response()->json([
                'message' => 'Menu created successfully',
                'data' => $menu
            ], 201);
        });
    }

    public function show($id): JsonResponse
    {
        $menu = Menu::findOrFail($id);
        return response()->json(['data' => $menu]);
    }

    public function update(UpdateMenuRequest $request, $id): JsonResponse
    {
        $menu = Menu::findOrFail($id);
        $menuData = $request->validated();
        unset($menuData['is_active']);

        $menu->update($menuData);

        return response()->json([
            'message' => 'Menu updated successfully',
            'data' => $menu
        ]);
    }

    public function destroy($id): JsonResponse
    {
        $menu = Menu::findOrFail($id);
        $menu->delete();

        return response()->json(['message' => 'Menu deleted successfully']);
    }
}