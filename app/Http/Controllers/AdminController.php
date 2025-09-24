<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class AdminController extends Controller
{
    public function self(Request $request)
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'message' => 'Unauthorized - No user found',
                    'success' => false
                ], 401);
            }

            // Temporarily return basic permissions to get the system working
            $permissions = ['dashboard'];

            return response()->json([
                'user' => $user,
                'permission' => $permissions,
                'success' => true
            ]);
        } catch (\Exception $e) {
            Log::error('Self endpoint error: ' . $e->getMessage());
            Log::error($e->getTraceAsString());
            
            return response()->json([
                'message' => 'Internal server error: ' . $e->getMessage(),
                'success' => false
            ], 500);
        }
    }
}