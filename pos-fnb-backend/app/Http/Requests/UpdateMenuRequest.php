<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateMenuRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'kode_menu' => [
                'sometimes',
                'required',
                'string',
                Rule::unique('menus', 'kode_menu')->ignore($this->route('menu'))->whereNull('deleted_at')
            ],
            'nama_menu' => 'sometimes|required|string|max:255',
            'kategori' => 'sometimes|required|string|max:255',
            'deskripsi' => 'nullable|string',
            'gambar' => 'nullable|url',
            'is_active' => 'boolean',
        ];
    }
}
