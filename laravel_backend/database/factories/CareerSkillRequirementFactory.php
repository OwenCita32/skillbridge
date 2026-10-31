<?php

namespace Database\Factories;

use App\Models\Career;
use App\Models\CareerSkillRequirement;
use App\Models\Skill;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<CareerSkillRequirement>
 */
class CareerSkillRequirementFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'career_id' => Career::factory(),
            'skill_id' => Skill::factory(),
            'target_level' => fake()->numberBetween(1, 5),
        ];
    }
}
