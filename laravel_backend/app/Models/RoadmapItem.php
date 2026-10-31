<?php

namespace App\Models;

use Database\Factories\RoadmapItemFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

#[Fillable(['roadmap_id', 'skill_id', 'position', 'title', 'description', 'estimated_hours', 'completion_criteria'])]
class RoadmapItem extends Model
{
    /** @use HasFactory<RoadmapItemFactory> */
    use HasFactory;

    public function roadmap(): BelongsTo
    {
        return $this->belongsTo(Roadmap::class);
    }

    public function skill(): BelongsTo
    {
        return $this->belongsTo(Skill::class);
    }

    public function resources(): BelongsToMany
    {
        return $this->belongsToMany(LearningResource::class, 'learning_resource_roadmap_item');
    }

    public function progressRecords(): HasMany
    {
        return $this->hasMany(ProgressRecord::class);
    }

    public function currentProgressRecord(): HasOne
    {
        return $this->hasOne(ProgressRecord::class)->latestOfMany();
    }
}
