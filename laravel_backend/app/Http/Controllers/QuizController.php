<?php

namespace App\Http\Controllers;

use App\Models\Assessment;
use App\Models\Skill;
use App\Services\SkillGapCalculator;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class QuizController extends Controller
{
    public function submit(Request $request, SkillGapCalculator $calculator): JsonResponse
    {
        $validated = $request->validate([
            'skill_name' => ['nullable', 'string'],
            'skill_id' => ['nullable', 'integer'],
            'score_percentage' => ['required', 'integer', 'min:0', 'max:100'],
            'correct_count' => ['nullable', 'integer'],
            'total_questions' => ['nullable', 'integer'],
        ]);

        $user = $request->user();
        $goal = $user->careerGoal()->with('career.skillRequirements.skill')->first();

        if (!$goal) {
            return response()->json(['message' => 'Pilih target karier terlebih dahulu.'], 400);
        }

        // Find matching skill within the user's active career requirements
        $careerSkillIds = $goal->career->skillRequirements->pluck('skill_id')->all();
        $skill = null;
        if (!empty($validated['skill_id']) && in_array((int) $validated['skill_id'], $careerSkillIds, true)) {
            $skill = Skill::find($validated['skill_id']);
        } elseif (!empty($validated['skill_name'])) {
            $skill = Skill::whereIn('id', $careerSkillIds)
                ->where('name', 'like', '%' . $validated['skill_name'] . '%')
                ->first();
        }

        // Fallback: pilih skill di karier ini yang masih belum mencapai target (gap terbesar)
        if (!$skill) {
            $latestAssessment = $user->assessments()
                ->where('career_id', $goal->career_id)
                ->with('skillAssessments')
                ->orderByDesc('submitted_at')
                ->first();
            $answers = $latestAssessment?->skillAssessments->keyBy('skill_id') ?? collect();

            $bestReq = $goal->career->skillRequirements
                ->sortByDesc(function ($req) use ($answers): int {
                    $cur = (int) ($answers->get($req->skill_id)?->level ?? 0);
                    return (int) $req->target_level - $cur;
                })
                ->first();

            $skill = $bestReq?->skill;
        }

        if (!$skill) {
            return response()->json(['message' => 'Skill tidak ditemukan.'], 404);
        }

        // Map quiz percentage to level 1-5
        // e.g. 0-20% = 1, 21-40% = 2, 41-60% = 3, 61-80% = 4, 81-100% = 5
        $pct = $validated['score_percentage'];
        $newLevel = (int) max(1, min(5, (int) ceil($pct / 20)));

        DB::transaction(function () use ($user, $goal, $skill, $newLevel) {
            // Find or create latest assessment
            $assessment = $user->assessments()
                ->where('career_id', $goal->career_id)
                ->orderByDesc('submitted_at')
                ->first();

            if (!$assessment) {
                $assessment = $user->assessments()->create([
                    'career_id' => $goal->career_id,
                    'submitted_at' => now(),
                ]);

                // Initialize all career skills to level 1
                foreach ($goal->career->skillRequirements as $req) {
                    $assessment->skillAssessments()->create([
                        'skill_id' => $req->skill_id,
                        'level' => $req->skill_id === $skill->id ? $newLevel : 1,
                    ]);
                }
            } else {
                // Update this skill's level
                $assessment->skillAssessments()->updateOrCreate(
                    ['skill_id' => $skill->id],
                    ['level' => $newLevel]
                );
            }
        });

        $gapAnalysis = $calculator->calculate($user);

        return response()->json([
            'message' => 'Skor kuis berhasil diterapkan ke skill ' . $skill->name . ' (Level ' . $newLevel . ').',
            'skill' => $skill,
            'new_level' => $newLevel,
            'score_percentage' => $pct,
            'skill_gaps' => $gapAnalysis,
        ]);
    }
}

