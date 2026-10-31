<?php

namespace App\Http\Resources;

use App\Enums\SkillLevel;
use App\Models\CareerSkillRequirement;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CareerResource extends JsonResource
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
            'slug' => $this->slug,
            'title' => $this->title,
            'summary' => $this->summary,
            'description' => $this->description,
            'is_demo' => $this->is_demo,
            'skills' => $this->whenLoaded('skillRequirements', fn (): array => $this->skillRequirements
                ->map(fn (CareerSkillRequirement $requirement): array => [
                    'id' => $requirement->skill->id,
                    'slug' => $requirement->skill->slug,
                    'name' => $requirement->skill->name,
                    'description' => $requirement->skill->description,
                    'category' => $requirement->skill->category,
                    'target_level' => $requirement->target_level,
                ])->all()),
            'assessment_scale' => SkillLevel::definitions(),
            'assessment_notice' => 'Penilaian ini adalah estimasi diri, bukan sertifikasi atau bukti kompetensi terverifikasi.',
        ];
    }
}
