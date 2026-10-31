<?php

namespace App\Http\Controllers;

use App\Http\Resources\RoadmapResource;
use App\Services\RoadmapGenerator;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RoadmapController extends Controller
{
    public function generate(Request $request, RoadmapGenerator $generator): JsonResponse
    {
        $user = $request->user();
        $goal = $user->careerGoal()->first();

        if ($goal === null) {
            return ApiResponse::error('CAREER_GOAL_REQUIRED', 'Pilih target karier sebelum membuat roadmap.', 409);
        }

        if (! $user->assessments()->where('career_id', $goal->career_id)->exists()) {
            return ApiResponse::error('ASSESSMENT_REQUIRED', 'Selesaikan self-assessment sebelum membuat roadmap.', 409);
        }

        $roadmap = $generator->generate($user);

        if ($roadmap === null) {
            return ApiResponse::error('ROADMAP_UNAVAILABLE', 'Roadmap belum dapat dibuat. Periksa target karier dan assessment Anda.', 409);
        }

        return ApiResponse::success(
            (new RoadmapResource($roadmap))->resolve($request),
            'Roadmap berhasil dibuat dari gap dan katalog resource terkurasi.',
            201,
        );
    }

    public function current(Request $request): JsonResponse
    {
        $roadmap = $request->user()->roadmaps()
            ->where('is_current', true)
            ->with(['career', 'items.skill', 'items.resources', 'items.currentProgressRecord'])
            ->orderByDesc('id')
            ->first();

        if ($roadmap === null) {
            return ApiResponse::error('ROADMAP_NOT_FOUND', 'Belum ada roadmap untuk target karier ini.', 404);
        }

        return ApiResponse::success(
            (new RoadmapResource($roadmap))->resolve($request),
            'Roadmap berhasil dimuat.',
        );
    }
}
