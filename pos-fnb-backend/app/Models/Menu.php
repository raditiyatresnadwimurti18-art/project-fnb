<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Menu extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'kode_menu',
        'nama_menu',
        'kategori',
        'deskripsi',
        'gambar',
        'price',
        'modal', // Removed is_active from fillable
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'modal' => 'decimal:2',
    ];

    protected $appends = [
        'total_stock',
        'is_active', // computed property
    ];

    public function inventoryBatches()
    {
        return $this->hasMany(InventoryBatch::class);
    }

    public function promos()
    {
        return $this->hasMany(Promo::class);
    }

    public function getTotalStockAttribute()
    {
        return $this->inventoryBatches()->sum('qty_remaining') ?? 0;
    }

    public function getIsActiveAttribute()
    {
        return $this->total_stock > 0;
    }
}