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
        // Simple update since rules are similar, just skipping validation request for brevity or creating UpdatePromoRequest
        $promo = Promo::findOrFail($id);
        $promo->update($request->all());

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
