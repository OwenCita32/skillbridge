<?php

namespace App\Models;

use Database\Factories\CareerSkillRequirementFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable(['career_id', 'skill_id', 'target_level'])]
class CareerSkillRequirement extends Model
{
    /** @use HasFactory<CareerSkillRequirementFactory> */
    use HasFactory;

    protected function casts(): array
    {
        return ['target_level' => 'integer'];
    }

    public function career(): BelongsTo
    {
        return $this->belongsTo(Career::class);
    }

    public function skill(): BelongsTo
    {
        return $this->belongsTo(Skill::class);
    }
}
