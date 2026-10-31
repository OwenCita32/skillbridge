<?php

namespace Database\Factories;

use App\Models\Career;
use App\Models\User;
use App\Models\UserCareerGoal;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<UserCareerGoal>
 */
class UserCareerGoalFactory extends Factory
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
        ];
    }
}
