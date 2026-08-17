<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
use Illuminate\Routing\Controllers\HasMiddleware;
use Illuminate\Routing\Controllers\Middleware;

class KasirController extends Controller implements HasMiddleware
{
    public static function middleware(): array
    {
        return [
            new Middleware(function ($request, $next) {
                if (!auth()->check()) {
                    return response()->json(['message' => 'Unauthenticated.'], 401);
                }

                $user = auth()->user();
                $action = $request->route()->getActionMethod();
                
                // index, store, destroy = Hanya Admin
                if (in_array($action, ['index', 'store', 'destroy']) && $user->role !== 'admin') {
                    return response()->json(['message' => 'Unauthorized. Admin access required.'], 403);
                }
                
                // show, update = Admin boleh, Kasir hanya boleh untuk ID-nya sendiri
                if (in_array($action, ['show', 'update']) && $user->role !== 'admin') {
                    $requestedId = $request->route('kasir'); // Mengambil parameter {kasir} dari URL
                    if ($user->id != $requestedId) {
                        return response()->json(['message' => 'Unauthorized. You can only access your own profile.'], 403);
                    }
                }
                
                return $next($request);
            }),
        ];
    }
    public function index(): JsonResponse
    {
        $kasir = User::where('role', 'kasir')->get();
        return response()->json(['data' => $kasir]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'username' => 'required|string|max:255|unique:users',
            'email' => 'nullable|email|max:255|unique:users',
            'password' => 'required|string|min:6',
        ]);

        $kasir = User::create([
            'name' => $validated['name'],
            'username' => $validated['username'],
            'email' => $validated['email'] ?? null,
            'password' => Hash::make($validated['password']),
            'role' => 'kasir',
        ]);

        return response()->json([
            'message' => 'Kasir created successfully',
            'data' => $kasir
        ], 201);
    }

    public function show($id): JsonResponse
    {
        $kasir = User::where('role', 'kasir')->findOrFail($id);
        return response()->json(['data' => $kasir]);
    }

    public function update(Request $request, $id): JsonResponse
    {
        $kasir = User::where('role', 'kasir')->findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'username' => ['sometimes', 'required', 'string', 'max:255', Rule::unique('users')->ignore($kasir->id)],
            'email' => ['nullable', 'email', 'max:255', Rule::unique('users')->ignore($kasir->id)],
            'password' => 'nullable|string|min:6',
        ]);

        if (isset($validated['password'])) {
            $validated['password'] = Hash::make($validated['password']);
        }

        $kasir->update($validated);

        return response()->json([
            'message' => 'Kasir updated successfully',
            'data' => $kasir
        ]);
    }

    public function destroy($id): JsonResponse
    {
        $kasir = User::where('role', 'kasir')->findOrFail($id);
        $kasir->delete();

        return response()->json(['message' => 'Kasir deleted successfully']);
    }
}
