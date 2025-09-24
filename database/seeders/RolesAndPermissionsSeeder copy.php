<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;
use Illuminate\Support\Facades\Log;

class RolesAndPermissionsSeeder extends Seeder
{
    public function run()
    {
        try {
            // Reset cached roles and permissions
            app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

            // Delete existing roles and permissions
            Role::query()->delete();
            Permission::query()->delete();

            // Create permissions
            $permissions = [
                'dashboard',
                'users',
                'roles',
                'settings',
                'products',
                'orders',
                'categories',
                'customers',
                'reports',
            ];

            $createdPermissions = [];
            foreach ($permissions as $permission) {
                $createdPermissions[] = Permission::create([
                    'name' => $permission,
                    'guard_name' => 'api'
                ]);
            }

            // Create admin role and give it all permissions
            $role = Role::create([
                'name' => 'admin',
                'guard_name' => 'api'
            ]);
            
            $role->givePermissionTo($createdPermissions);
            
        } catch (\Exception $e) {
            Log::error('RolesAndPermissionsSeeder error: ' . $e->getMessage());
            throw $e;
        }
    }
}