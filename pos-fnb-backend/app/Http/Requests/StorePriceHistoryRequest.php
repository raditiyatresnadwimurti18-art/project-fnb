<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StorePriceHistoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'new_price' => 'required|numeric|min:0',
            'effective_date' => 'required|date',
            'user_id' => 'nullable|exists:users,id',
        ];
    }
}
