<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class LearningResourceResource extends JsonResource
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
            'title' => $this->title,
            'description' => $this->description,
            'category' => $this->category,
            'type' => $this->type,
            'url' => $this->url,
            'source' => $this->source,
            'verified_at' => $this->verified_at?->toDateString(),
            'is_demo' => $this->is_demo,
        ];
    }
}
