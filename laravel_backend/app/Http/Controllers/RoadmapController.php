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

    public function current(Request $request, RoadmapGenerator $generator): JsonResponse
    {
        $user = $request->user();
        $roadmap = $user->roadmaps()
            ->where('is_current', true)
            ->with(['career', 'items.skill', 'items.resources', 'items.currentProgressRecord'])
            ->orderByDesc('id')
            ->first();

        if ($roadmap === null) {
            $goal = $user->careerGoal()->with('career.skillRequirements')->first();

            // Auto-assign default UI/UX Designer career if none selected
            if (!$goal) {
                $career = \App\Models\Career::where('slug', 'ui-ux-designer')->first();
                if ($career) {
                    $goal = $user->careerGoal()->create(['career_id' => $career->id]);
                    $goal->load('career.skillRequirements');
                }
            }

            if ($goal) {
                // Ensure initial assessment exists
                if (!$user->assessments()->where('career_id', $goal->career_id)->exists()) {
                    $assessment = $user->assessments()->create([
                        'career_id' => $goal->career_id,
                        'submitted_at' => now(),
                    ]);
                    foreach ($goal->career->skillRequirements as $req) {
                        $assessment->skillAssessments()->create([
                            'skill_id' => $req->skill_id,
                            'level' => max(1, min(2, $req->target_level - 1)),
                        ]);
                    }
                }

                $roadmap = $generator->generate($user);
                if ($roadmap) {
                    $roadmap->load(['career', 'items.skill', 'items.resources', 'items.currentProgressRecord']);
                }
            }
        }

        if ($roadmap === null) {
            return ApiResponse::error('ROADMAP_NOT_FOUND', 'Belum ada roadmap untuk target karier ini.', 404);
        }

        return ApiResponse::success(
            (new RoadmapResource($roadmap))->resolve($request),
            'Roadmap berhasil dimuat.',
        );
    }
}
