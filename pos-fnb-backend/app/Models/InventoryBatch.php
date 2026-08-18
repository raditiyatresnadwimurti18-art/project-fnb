<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class InventoryBatch extends Model
{
    protected $fillable = [
        'menu_id',
        'qty_purchased',
        'qty_remaining',
        'modal',
        'purchased_at',
    ];

    protected $casts = [
        'purchased_at' => 'datetime',
        'modal' => 'decimal:2',
    ];

    public function menu()
    {
        return $this->belongsTo(Menu::class);
    }
}
