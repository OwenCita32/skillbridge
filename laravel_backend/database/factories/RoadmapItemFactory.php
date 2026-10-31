<?php

namespace Database\Factories;

use App\Models\Roadmap;
use App\Models\RoadmapItem;
use App\Models\Skill;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<RoadmapItem>
 */
class RoadmapItemFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'roadmap_id' => Roadmap::factory(),
            'skill_id' => Skill::factory(),
            'position' => fake()->unique()->numberBetween(1, 1000),
            'title' => fake()->sentence(4),
            'description' => fake()->paragraph(),
            'estimated_hours' => fake()->numberBetween(1, 8),
            'completion_criteria' => fake()->sentence(),
        ];
    }
}
