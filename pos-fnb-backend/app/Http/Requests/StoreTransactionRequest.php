<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreTransactionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'items' => 'required|array|min:1',
            'items.*.menu_id' => 'required|exists:menus,id',
            'items.*.qty' => 'required|integer|min:1',
            'promo_id' => 'nullable|exists:promos,id',
            'payment_amount' => 'required|numeric|min:0',
            'user_id' => 'nullable|exists:users,id',
        ];
    }
}
