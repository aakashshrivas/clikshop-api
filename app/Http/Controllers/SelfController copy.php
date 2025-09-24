<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class SelfController extends Controller
{
    public function index(Request $request)
    {
        try {
            $user = $request->user();
            return response()->json([
                'user' => $user,
                'permission' => $user->getAllPermissions(),
                'success' => true
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage(),
                'success' => false
            ], 500);
        }
    }
}