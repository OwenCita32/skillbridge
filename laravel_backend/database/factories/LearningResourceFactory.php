<?php

namespace Database\Factories;

use App\Models\LearningResource;
use App\Models\Skill;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<LearningResource>
 */
class LearningResourceFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'skill_id' => Skill::factory(),
            'title' => fake()->sentence(4),
            'description' => fake()->paragraph(),
            'category' => fake()->word(),
            'type' => 'reference',
            'url' => 'https://example.test/resource',
            'source' => 'Test fixture',
            'verified_at' => now()->toDateString(),
            'is_active' => true,
            'is_demo' => true,
        ];
    }
}
