<?php

namespace App\Models;

use Database\Factories\CareerFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable(['slug', 'title', 'summary', 'description', 'is_demo'])]
class Career extends Model
{
    /** @use HasFactory<CareerFactory> */
    use HasFactory;

    protected function casts(): array
    {
        return ['is_demo' => 'boolean'];
    }

    public function skillRequirements(): HasMany
    {
        return $this->hasMany(CareerSkillRequirement::class);
    }

    public function skills(): BelongsToMany
    {
        return $this->belongsToMany(Skill::class, 'career_skill_requirements')
            ->withPivot('target_level');
    }
}
