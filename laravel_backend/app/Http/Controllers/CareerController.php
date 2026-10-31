<?php

namespace App\Http\Controllers;

use App\Http\Resources\CareerResource;
use App\Models\Career;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class CareerController extends Controller
{
    public function index(): AnonymousResourceCollection
    {
        return CareerResource::collection(
            Career::query()
                ->with('skillRequirements.skill')
                ->orderBy('title')
                ->paginate(20),
        )->additional(['message' => 'Daftar karier berhasil dimuat.']);
    }

    public function show(Request $request, Career $career): JsonResponse
    {
        $career->load('skillRequirements.skill');

        return ApiResponse::success(
            (new CareerResource($career))->resolve($request),
            'Detail karier berhasil dimuat.',
        );
    }
}
