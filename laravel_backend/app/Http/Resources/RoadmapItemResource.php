<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RoadmapItemResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'position' => $this->position,
            'skill' => $this->whenLoaded('skill', fn (): array => [
                'id' => $this->skill->id,
                'name' => $this->skill->name,
            ]),
            'title' => $this->title,
            'description' => $this->description,
            'estimated_hours' => $this->estimated_hours,
            'completion_criteria' => $this->completion_criteria,
            'status' => $this->currentProgressRecord?->status ?? 'not_started',
            'resources' => LearningResourceResource::collection($this->whenLoaded('resources')),
        ];
    }
}
