<?php

namespace App\Http\Resources;

use App\Enums\SkillLevel;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SkillGapResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'skill' => [
                'id' => $this['skill']->id,
                'slug' => $this['skill']->slug,
                'name' => $this['skill']->name,
                'description' => $this['skill']->description,
            ],
            'current_level' => $this['current_level'],
            'current_level_label' => $this['current_level'] === null
                ? null
                : SkillLevel::from($this['current_level'])->label(),
            'target_level' => $this['target_level'],
            'target_level_label' => SkillLevel::from($this['target_level'])->label(),
            'gap' => $this['gap'],
            'is_assessed' => $this['current_level'] !== null,
            'priority' => $this['priority'],
            'explanation' => $this['explanation'] ?? null,
            'suggested_next_action' => $this['suggested_next_action'] ?? null,
        ];
    }
}
