<?php

namespace App\Http\Controllers;

use App\Http\Resources\CareerResource;
use App\Http\Resources\SkillGapResource;
use App\Services\SkillGapExplanationService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SkillGapExplanationController extends Controller
{
    public function store(Request $request, SkillGapExplanationService $service): JsonResponse
    {
        $explanation = $service->explain($request->user());

        if ($explanation === null) {
            return ApiResponse::error('CAREER_GOAL_REQUIRED', 'Pilih target karier sebelum meminta penjelasan skill gap.', 409);
        }

        return ApiResponse::success([
            'career' => (new CareerResource($explanation['career']))->resolve($request),
            'assessment_id' => $explanation['assessment']?->id,
            'explanation_source' => $explanation['explanation_source'],
            'model' => $explanation['model'],
            'fallback_reason' => $explanation['fallback_reason'],
            'skills' => SkillGapResource::collection(collect($explanation['skills']))->resolve($request),
        ], 'Penjelasan skill gap berhasil disusun.');
    }
}
