<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class TestUserSeeder extends Seeder
{
    public function run()
    {
        $user = User::firstOrNew(['email' => 'admin@example.com']);
        
        if (!$user->exists) {
            $user->fill([
                'name' => 'Admin User',
                'password' => Hash::make('password'),
                'is_approved' => true,
                'status' => true,
            ])->save();
        }

        $user->assignRole('admin');
    }
}