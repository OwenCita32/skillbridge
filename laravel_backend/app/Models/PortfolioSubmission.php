<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PortfolioSubmission extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'roadmap_item_id',
        'title',
        'submission_link',
        'checklist_completed',
    ];

    protected $casts = [
        'checklist_completed' => 'array',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function roadmapItem(): BelongsTo
    {
        return $this->belongsTo(RoadmapItem::class);
    }
}

