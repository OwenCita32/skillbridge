<?php

namespace App\Http\Resources;

use App\Enums\SkillLevel;
use App\Models\UserSkillAssessment;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AssessmentResource extends JsonResource
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
            'submitted_at' => $this->submitted_at?->toIso8601String(),
            'assessment_type' => 'self_assessment',
            'is_verified' => false,
            'notice' => 'Hasil ini adalah penilaian diri, bukan sertifikasi atau bukti kompetensi terverifikasi.',
            'answers' => $this->whenLoaded('skillAssessments', fn (): array => $this->skillAssessments
                ->map(fn (UserSkillAssessment $answer): array => [
                    'skill_id' => $answer->skill_id,
                    'skill_name' => $answer->skill->name,
                    'level' => $answer->level,
                    'level_label' => SkillLevel::from($answer->level)->label(),
                ])->all()),
        ];
    }
}
