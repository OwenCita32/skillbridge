<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RoadmapResource extends JsonResource
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
            'career_id' => $this->career_id,
            'career_title' => $this->career?->title,
            'summary' => $this->summary,
            'generation_mode' => $this->generation_mode,
            'generation_model' => $this->generation_model,
            'generated_at' => $this->generated_at?->toIso8601String(),
            'items' => RoadmapItemResource::collection($this->whenLoaded('items')),
        ];
    }
}
