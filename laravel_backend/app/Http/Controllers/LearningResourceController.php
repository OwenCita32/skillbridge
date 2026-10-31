<?php

namespace App\Http\Controllers;

use App\Http\Resources\LearningResourceResource;
use App\Models\LearningResource;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class LearningResourceController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $filters = $request->validate([
            'skill_id' => ['sometimes', 'integer', 'exists:skills,id'],
            'category' => ['sometimes', 'string', 'max:80'],
        ]);
        $resources = LearningResource::query()
            ->where('is_active', true)
            ->whereNotNull('verified_at')
            ->when(isset($filters['skill_id']), fn ($query) => $query->where('skill_id', $filters['skill_id']))
            ->when(isset($filters['category']), fn ($query) => $query->where('category', $filters['category']))
            ->orderBy('title')
            ->paginate(20);

        return LearningResourceResource::collection($resources)
            ->additional(['message' => 'Katalog resource berhasil dimuat.']);
    }
}
