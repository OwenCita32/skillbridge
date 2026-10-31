<?php

namespace App\Models;

use Database\Factories\RoadmapFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable(['user_id', 'career_id', 'generation_mode', 'generation_model', 'summary', 'is_current', 'generated_at'])]
class Roadmap extends Model
{
    /** @use HasFactory<RoadmapFactory> */
    use HasFactory;

    protected function casts(): array
    {
        return ['is_current' => 'boolean', 'generated_at' => 'datetime'];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function career(): BelongsTo
    {
        return $this->belongsTo(Career::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(RoadmapItem::class)->orderBy('position');
    }
}
