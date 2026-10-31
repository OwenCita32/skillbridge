<?php

namespace Database\Factories;

use App\Models\ProgressRecord;
use App\Models\RoadmapItem;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<ProgressRecord>
 */
class ProgressRecordFactory extends Factory
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
            'roadmap_item_id' => RoadmapItem::factory(),
            'status' => 'not_started',
        ];
    }
}
