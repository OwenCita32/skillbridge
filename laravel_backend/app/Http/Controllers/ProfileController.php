<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Concerns\ManagesCareerCertificates;
use App\Http\Controllers\Concerns\ManagesGithubAndLinkedInPortfolio;
use App\Http\Resources\UserResource;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    use ManagesCareerCertificates;
    use ManagesGithubAndLinkedInPortfolio;

    public function show(Request $request): JsonResponse
    {
        $user = $request->user()->load('careerGoal.career');

        return ApiResponse::success([
            'user' => (new UserResource($user))->resolve($request),
        ], 'Profil berhasil dimuat.');
    }

    public function update(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|min:2|max:255',
            'headline' => 'nullable|string|max:255',
            'github_username' => 'nullable|string|max:100',
            'linkedin_url' => 'nullable|string|max:255',
            'bio' => 'nullable|string|max:1000',
            'avatar_url' => 'nullable|string|max:1000',
        ]);

        $user = $request->user();
        $user->update([
            'name' => trim($validated['name']),
            'headline' => isset($validated['headline']) ? trim($validated['headline']) : $user->headline,
            'github_username' => isset($validated['github_username']) ? trim($validated['github_username']) : $user->github_username,
            'linkedin_url' => isset($validated['linkedin_url']) ? trim($validated['linkedin_url']) : $user->linkedin_url,
            'bio' => isset($validated['bio']) ? trim($validated['bio']) : $user->bio,
            'avatar_url' => isset($validated['avatar_url']) ? trim($validated['avatar_url']) : $user->avatar_url,
        ]);

        $user->load('careerGoal.career');

        return ApiResponse::success([
            'user' => (new UserResource($user))->resolve($request),
        ], 'Profil berhasil diperbarui.');
    }
}
