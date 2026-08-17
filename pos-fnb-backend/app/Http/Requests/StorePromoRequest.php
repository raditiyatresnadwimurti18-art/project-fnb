<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StorePromoRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255',
            'type' => 'required|in:discount,bogo',
            'value' => 'nullable|required_if:type,discount|numeric|min:0',
            'is_percentage' => 'boolean',
            'max_discount' => 'nullable|numeric|min:0',
            'min_purchase' => 'nullable|numeric|min:0',
            'buy_qty' => 'nullable|required_if:type,bogo|integer|min:1',
            'free_qty' => 'nullable|required_if:type,bogo|integer|min:1',
            'apply_multiple' => 'boolean',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'quota' => 'nullable|integer|min:1',
            'is_active' => 'boolean',
            'menu_id' => 'nullable|exists:menus,id',
        ];
    }
}
