<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreCareerGoalRequest;
use App\Http\Resources\CareerResource;
use App\Models\Career;
use App\Models\UserCareerGoal;
use App\Services\CustomCareerService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class CareerGoalController extends Controller
{
    public function store(StoreCareerGoalRequest $request, CustomCareerService $customCareerService): JsonResponse
    {
        $goal = DB::transaction(function () use ($request, $customCareerService): UserCareerGoal {
            $user = $request->user();
            $careerId = $request->validated('career_id');
            $careerTitle = $request->validated('career_title');

            if ($careerId === null && $careerTitle !== null) {
                $career = $customCareerService->resolveOrCreate($careerTitle);
                $targetCareerId = $career->id;
            } else {
                $targetCareerId = (int) $careerId;
            }

            $previousCareerId = UserCareerGoal::where('user_id', $user->id)->value('career_id');
            $goal = UserCareerGoal::updateOrCreate(
                ['user_id' => $user->id],
                ['career_id' => $targetCareerId],
            );

            if ($previousCareerId !== null && (int) $previousCareerId !== $targetCareerId) {
                $user->roadmaps()->where('is_current', true)->update(['is_current' => false]);
            }

            return $goal;
        });

        $career = Career::with('skillRequirements.skill')->findOrFail($goal->career_id);

        return ApiResponse::success(
            ['career' => (new CareerResource($career))->resolve($request)],
            'Target karier berhasil disimpan.',
        );
    }
}
