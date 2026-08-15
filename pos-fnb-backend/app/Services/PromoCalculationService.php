<?php

namespace App\Services;

use App\Models\Promo;
use App\Models\Menu;
use Carbon\Carbon;

class PromoCalculationService
{
    /**
     * Calculate discount for a given cart based on promo.
     * Returns an array containing the applied discount amount and the new total.
     */
    public function calculate(array $items, Promo $promo = null)
    {
        $subtotal = 0;
        $itemsData = [];

        // Calculate Subtotal
        foreach ($items as $item) {
            $menu = Menu::with('currentPrice')->find($item['menu_id']);
            if (!$menu) continue;

            $price = $menu->currentPrice ? (float) $menu->currentPrice->new_price : 0;
            $itemSubtotal = $price * $item['qty'];
            $subtotal += $itemSubtotal;

            $itemsData[] = [
                'menu_id' => $menu->id,
                'qty' => $item['qty'],
                'price' => $price,
                'subtotal' => $itemSubtotal,
            ];
        }

        $discountAmount = 0;

        if ($promo && $this->isPromoValid($promo, $subtotal)) {
            if ($promo->type === 'discount') {
                $discountAmount = $this->calculateDiscount($promo, $subtotal);
            } elseif ($promo->type === 'bogo') {
                $discountAmount = $this->calculateBogo($promo, $itemsData);
            }
        }

        $totalAmount = max(0, $subtotal - $discountAmount);

        return [
            'subtotal' => $subtotal,
            'discount_amount' => $discountAmount,
            'total_amount' => $totalAmount,
            'items' => $itemsData,
            'promo_id' => $promo ? $promo->id : null,
        ];
    }

    private function isPromoValid(Promo $promo, $subtotal)
    {
        if (!$promo->is_active) return false;
        
        $now = Carbon::now();
        if ($now->lt($promo->start_date) || $now->gt($promo->end_date)) return false;
        
        if ($promo->quota !== null && $promo->used_quota >= $promo->quota) return false;
        
        if ($promo->min_purchase !== null && $subtotal < (float) $promo->min_purchase) return false;

        return true;
    }

    private function calculateDiscount(Promo $promo, $subtotal)
    {
        if ($promo->is_percentage) {
            $discount = $subtotal * ((float) $promo->value / 100);
            if ($promo->max_discount !== null && $discount > (float) $promo->max_discount) {
                return (float) $promo->max_discount;
            }
            return $discount;
        }

        return (float) $promo->value;
    }

    private function calculateBogo(Promo $promo, $itemsData)
    {
        $totalQty = array_sum(array_column($itemsData, 'qty'));
        if ($promo->buy_qty === null || $totalQty < $promo->buy_qty) return 0;
        
        $multiplier = 1;
        if ($promo->apply_multiple) {
            $multiplier = floor($totalQty / $promo->buy_qty);
        }

        $freeItemsAllowed = $multiplier * ($promo->free_qty ?? 1);
        
        if ($freeItemsAllowed <= 0) return 0;

        // Sort items by price ascending to discount the cheapest items
        usort($itemsData, function ($a, $b) {
            return $a['price'] <=> $b['price'];
        });

        $discount = 0;
        $freeItemsGiven = 0;

        foreach ($itemsData as $item) {
            $qtyToDiscount = min($item['qty'], $freeItemsAllowed - $freeItemsGiven);
            if ($qtyToDiscount > 0) {
                $discount += $item['price'] * $qtyToDiscount;
                $freeItemsGiven += $qtyToDiscount;
            }

            if ($freeItemsGiven >= $freeItemsAllowed) {
                break;
            }
        }

        return $discount;
    }
}
