<?php

namespace Database\Factories;

use App\Models\Assessment;
use App\Models\Skill;
use App\Models\UserSkillAssessment;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<UserSkillAssessment>
 */
class UserSkillAssessmentFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'assessment_id' => Assessment::factory(),
            'skill_id' => Skill::factory(),
            'level' => fake()->numberBetween(0, 5),
        ];
    }
}
