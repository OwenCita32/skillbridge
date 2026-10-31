<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreAssessmentRequest;
use App\Http\Resources\AssessmentResource;
use App\Models\Assessment;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AssessmentController extends Controller
{
    public function store(StoreAssessmentRequest $request): JsonResponse
    {
        $user = $request->user();
        $goal = $user->careerGoal()->with('career.skillRequirements')->first();

        if ($goal === null) {
            return ApiResponse::error('CAREER_GOAL_REQUIRED', 'Pilih target karier sebelum mengisi assessment.', 409);
        }

        $answers = $request->validated('answers');
        $expectedSkillIds = $goal->career->skillRequirements
            ->pluck('skill_id')->map(fn ($id): int => (int) $id)->sort()->values()->all();
        $submittedSkillIds = collect($answers)
            ->pluck('skill_id')->map(fn ($id): int => (int) $id)->sort()->values()->all();

        if ($expectedSkillIds !== $submittedSkillIds) {
            return ApiResponse::error(
                'ASSESSMENT_SKILLS_MISMATCH',
                'Nilai harus mencakup setiap skill target tepat satu kali.',
                422,
            );
        }

        $assessment = DB::transaction(function () use ($answers, $goal, $user): Assessment {
            $assessment = $user->assessments()->create([
                'career_id' => $goal->career_id,
                'submitted_at' => now(),
            ]);
            $assessment->skillAssessments()->createMany(
                collect($answers)->map(fn (array $answer): array => [
                    'skill_id' => (int) $answer['skill_id'],
                    'level' => (int) $answer['level'],
                ])->all(),
            );

            return $assessment;
        });
        $assessment->load('skillAssessments.skill');

        return ApiResponse::success(
            (new AssessmentResource($assessment))->resolve($request),
            'Self-assessment berhasil disimpan.',
            201,
        );
    }

    public function show(Request $request, Assessment $assessment): JsonResponse
    {
        abort_unless($assessment->user_id === $request->user()->id, 404);
        $assessment->load('skillAssessments.skill');

        return ApiResponse::success(
            (new AssessmentResource($assessment))->resolve($request),
            'Hasil assessment berhasil dimuat.',
        );
    }
}
