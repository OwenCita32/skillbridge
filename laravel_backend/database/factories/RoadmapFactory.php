<?php

namespace Database\Factories;

use App\Models\Career;
use App\Models\Roadmap;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Roadmap>
 */
class RoadmapFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'career_id' => Career::factory(),
            'generation_mode' => 'deterministic_fallback',
            'summary' => fake()->sentence(),
            'is_current' => true,
            'generated_at' => now(),
        ];
    }
}
