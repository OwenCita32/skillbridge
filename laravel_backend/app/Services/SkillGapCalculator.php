<?php

namespace App\Services;

use App\Enums\SkillLevel;
use App\Models\Assessment;
use App\Models\Career;
use App\Models\CareerSkillRequirement;
use App\Models\User;
use Illuminate\Support\Collection;

class SkillGapCalculator
{
    /** @return array{career: Career, assessment: ?Assessment, skills: list<array<string, mixed>>}|null */
    public function calculate(User $user): ?array
    {
        $goal = $user->careerGoal()->with('career.skillRequirements.skill')->first();

        if ($goal === null) {
            return null;
        }

        $assessment = $user->assessments()
            ->where('career_id', $goal->career_id)
            ->with('skillAssessments')
            ->orderByDesc('submitted_at')
            ->orderByDesc('id')
            ->first();
        $answers = $assessment?->skillAssessments->keyBy('skill_id') ?? new Collection;

        $skills = $goal->career->skillRequirements
            ->sortBy(fn (CareerSkillRequirement $requirement): int => $requirement->skill_id)
            ->map(function (CareerSkillRequirement $requirement) use ($answers): array {
                $currentLevel = $answers->get($requirement->skill_id)?->level;
                $targetLevel = $requirement->target_level;
                $gap = SkillLevel::gap($currentLevel, $targetLevel);

                return [
                    'skill' => $requirement->skill,
                    'current_level' => $currentLevel,
                    'target_level' => $targetLevel,
                    'gap' => $gap,
                    'priority' => $gap === null ? 'unassessed' : ($gap > 0 ? 'focus' : 'on_track'),
                ];
            })
            ->values()
            ->all();

        return ['career' => $goal->career, 'assessment' => $assessment, 'skills' => $skills];
    }
}
