<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;
use Spatie\Permission\Models\Role;

class AssignAdminRole extends Command
{
    protected $signature = 'user:make-admin {email}';
    protected $description = 'Assigns the admin role to a user';

    public function handle()
    {
        $email = $this->argument('email');
        $user = User::where('email', $email)->first();

        if (!$user) {
            $this->error("User with email {$email} not found.");
            return 1;
        }

        $role = Role::where('name', 'admin')->first();
        if (!$role) {
            $this->error("Admin role not found. Please run the RolesAndPermissionsSeeder first.");
            return 1;
        }

        $user->syncRoles([$role]);
        $this->info("Admin role assigned to user {$email} successfully.");

        return 0;
    }
}