<?php

namespace App\Http\Controllers;

use App\Services\AiMentorService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AiMentorController extends Controller
{
    public function chat(Request $request, AiMentorService $mentorService): JsonResponse
    {
        $validated = $request->validate([
            'message' => 'required|string|min:2|max:1000',
            'history' => 'sometimes|array',
            'history.*.role' => 'required_with:history|string|in:user,assistant',
            'history.*.content' => 'required_with:history|string|max:1000',
        ]);

        $result = $mentorService->chat(
            $request->user(),
            $validated['message'],
            $validated['history'] ?? []
        );

        return ApiResponse::success([
            'reply' => $result['reply'],
            'source' => $result['source'],
            'model' => $result['model'],
            'created_at' => now()->toISOString(),
        ], 'Jawaban AI Mentor berhasil didapatkan.');
    }
}

