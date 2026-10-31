<?php

namespace App\Models;

use Database\Factories\AssessmentFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable(['user_id', 'career_id', 'submitted_at'])]
class Assessment extends Model
{
    /** @use HasFactory<AssessmentFactory> */
    use HasFactory;

    protected function casts(): array
    {
        return ['submitted_at' => 'datetime'];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function career(): BelongsTo
    {
        return $this->belongsTo(Career::class);
    }

    public function skillAssessments(): HasMany
    {
        return $this->hasMany(UserSkillAssessment::class);
    }
}
