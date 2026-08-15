<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreMenuRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'kode_menu' => [
                'required',
                'string',
                Rule::unique('menus', 'kode_menu')->whereNull('deleted_at')
            ],
            'nama_menu' => 'required|string|max:255',
            'kategori' => 'required|string|max:255',
            'deskripsi' => 'nullable|string',
            'gambar' => 'nullable|url', // Assuming we are accepting URLs based on requirements
            'is_active' => 'boolean',
            'price' => 'required|numeric|min:0',
        ];
    }
}
