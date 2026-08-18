<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        User::updateOrCreate(
            ['email' => 'admin@pos.com'],
            [
                'name' => 'Admin POS',
                'username' => 'admin',
                'role' => 'admin',
                'password' => Hash::make('password'),
            ]
        );
    }
}
