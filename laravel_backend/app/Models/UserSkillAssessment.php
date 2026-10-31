<?php

namespace App\Models;

use Database\Factories\UserSkillAssessmentFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable(['assessment_id', 'skill_id', 'level'])]
class UserSkillAssessment extends Model
{
    /** @use HasFactory<UserSkillAssessmentFactory> */
    use HasFactory;

    protected function casts(): array
    {
        return ['level' => 'integer'];
    }

    public function assessment(): BelongsTo
    {
        return $this->belongsTo(Assessment::class);
    }

    public function skill(): BelongsTo
    {
        return $this->belongsTo(Skill::class);
    }
}
