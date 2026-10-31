<?php

namespace Database\Factories;

use App\Models\Assessment;
use App\Models\Career;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Assessment>
 */
class AssessmentFactory extends Factory
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
            'submitted_at' => now(),
        ];
    }
}
