<?php

namespace App\Models;

use Database\Factories\LearningResourceFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

#[Fillable(['skill_id', 'title', 'description', 'category', 'type', 'url', 'source', 'verified_at', 'is_active', 'is_demo'])]
class LearningResource extends Model
{
    /** @use HasFactory<LearningResourceFactory> */
    use HasFactory;

    protected function casts(): array
    {
        return ['verified_at' => 'date', 'is_active' => 'boolean', 'is_demo' => 'boolean'];
    }

    public function skill(): BelongsTo
    {
        return $this->belongsTo(Skill::class);
    }

    public function roadmapItems(): BelongsToMany
    {
        return $this->belongsToMany(RoadmapItem::class, 'learning_resource_roadmap_item');
    }
}
