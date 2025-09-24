<?php

namespace App\Http\Controllers;

use App\Models\Setting;
use App\Http\Requests\UpdateSettingRequest;
use App\Repositories\Eloquents\SettingRepository;

class SettingController extends Controller
{
    public $repository;

    public function __construct(SettingRepository $repository)
    {
        $this->repository = $repository;
    }

    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        try {
            $settings = $this->repository->index();
            return response()->json([
                'data' => $settings,
                'success' => true
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Could not load settings',
                'success' => false
            ], 200); // Return 200 with error message instead of 500
        }
    }

    public function update(UpdateSettingRequest $request, Setting $setting)
    {
        return $this->repository->update($request->all(), null);
    }
}
