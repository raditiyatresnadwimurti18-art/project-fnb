<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Promo;
use App\Http\Requests\StorePromoRequest;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class PromoController extends Controller
{
    public function index(): JsonResponse
    {
        $promos = Promo::all();
        return response()->json(['data' => $promos]);
    }

    public function store(StorePromoRequest $request): JsonResponse
    {
        $promo = Promo::create($request->validated());
        return response()->json([
            'message' => 'Promo created successfully',
            'data' => $promo
        ], 201);
    }

    public function show($id): JsonResponse
    {
        $promo = Promo::findOrFail($id);
        return response()->json(['data' => $promo]);
    }

    public function update(Request $request, $id): JsonResponse
    {
        $promo = Promo::findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'type' => 'sometimes|required|in:discount,bogo',
            'value' => 'nullable|numeric|min:0',
            'is_percentage' => 'boolean',
            'max_discount' => 'nullable|numeric|min:0',
            'min_purchase' => 'nullable|numeric|min:0',
            'buy_qty' => 'nullable|integer|min:1',
            'free_qty' => 'nullable|integer|min:1',
            'apply_multiple' => 'boolean',
            'start_date' => 'sometimes|required|date',
            'end_date' => 'sometimes|required|date|after_or_equal:start_date',
            'is_active' => 'boolean',
            'menu_id' => 'nullable|exists:menus,id',
            'free_menu_id' => 'nullable|required_if:type,bogo|exists:menus,id',
        ]);

        // Protect system-managed fields from manual tampering
        unset($validated['used_quota']);
        unset($validated['quota']);

        $promo->update($validated);

        return response()->json([
            'message' => 'Promo updated successfully',
            'data' => $promo
        ]);
    }

    public function destroy($id): JsonResponse
    {
        $promo = Promo::findOrFail($id);
        $promo->delete();

        return response()->json(['message' => 'Promo deleted successfully']);
    }
}
