<?php

namespace App\Http\Controllers;

use App\Http\Resources\CareerResource;
use App\Http\Resources\SkillGapResource;
use App\Services\SkillGapCalculator;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SkillGapController extends Controller
{
    public function index(Request $request, SkillGapCalculator $calculator): JsonResponse
    {
        $analysis = $calculator->calculate($request->user());

        if ($analysis === null) {
            return ApiResponse::error('CAREER_GOAL_REQUIRED', 'Pilih target karier sebelum melihat skill gap.', 409);
        }

        return ApiResponse::success([
            'career' => (new CareerResource($analysis['career']))->resolve($request),
            'assessment_id' => $analysis['assessment']?->id,
            'assessment_notice' => 'Level kemampuan adalah penilaian diri dan tidak menyatakan kompetensi terverifikasi.',
            'skills' => SkillGapResource::collection(collect($analysis['skills']))->resolve($request),
        ], 'Analisis skill gap berhasil dimuat.');
    }
}
