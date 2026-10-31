<?php

namespace App\Http\Controllers;

use App\Models\PortfolioSubmission;
use App\Models\RoadmapItem;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PortfolioSubmissionController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'submission_link' => ['nullable', 'string', 'max:1000'],
            'checklist_completed' => ['nullable', 'array'],
            'roadmap_item_id' => ['nullable', 'exists:roadmap_items,id'],
        ]);

        $submission = $request->user()->portfolioSubmissions()->create([
            'title' => $validated['title'],
            'submission_link' => $validated['submission_link'] ?? null,
            'checklist_completed' => $validated['checklist_completed'] ?? null,
            'roadmap_item_id' => $validated['roadmap_item_id'] ?? null,
        ]);

        // Auto-complete roadmap item if attached
        if (!empty($validated['roadmap_item_id'])) {
            $item = RoadmapItem::where('id', $validated['roadmap_item_id'])
                ->whereHas('roadmap', fn ($q) => $q->where('user_id', $request->user()->id))
                ->first();

            if ($item) {
                $item->update(['status' => 'completed']);
            }
        }

        return response()->json([
            'message' => 'Hasil praktik berhasil dikirim & diverifikasi.',
            'submission' => $submission,
        ], 201);
    }
}

