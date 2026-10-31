<?php

namespace App\Http\Controllers;

use App\Http\Requests\UpdateRoadmapProgressRequest;
use App\Models\ProgressRecord;
use App\Models\RoadmapItem;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;

class RoadmapItemProgressController extends Controller
{
    public function update(UpdateRoadmapProgressRequest $request, int $item): JsonResponse
    {
        $roadmapItem = RoadmapItem::query()
            ->whereKey($item)
            ->whereHas('roadmap', fn ($query) => $query
                ->where('user_id', $request->user()->id)
                ->where('is_current', true))
            ->firstOrFail();
        $progress = ProgressRecord::create([
            'user_id' => $request->user()->id,
            'roadmap_item_id' => $roadmapItem->id,
            'status' => $request->validated('status'),
        ]);

        return ApiResponse::success([
            'roadmap_item_id' => $roadmapItem->id,
            'status' => $progress->status,
            'updated_at' => $progress->created_at->toIso8601String(),
        ], 'Progress berhasil disimpan.');
    }
}
