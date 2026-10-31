<?php

namespace App\Models;

use Database\Factories\SkillFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable(['slug', 'name', 'description', 'category', 'is_demo'])]
class Skill extends Model
{
    /** @use HasFactory<SkillFactory> */
    use HasFactory;

    protected function casts(): array
    {
        return ['is_demo' => 'boolean'];
    }

    public function careerRequirements(): HasMany
    {
        return $this->hasMany(CareerSkillRequirement::class);
    }

    public function careers(): BelongsToMany
    {
        return $this->belongsToMany(Career::class, 'career_skill_requirements')
            ->withPivot('target_level');
    }

    public function learningResources(): HasMany
    {
        return $this->hasMany(LearningResource::class);
    }
}
