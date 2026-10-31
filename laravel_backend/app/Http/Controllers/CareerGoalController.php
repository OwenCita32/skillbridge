<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreCareerGoalRequest;
use App\Http\Resources\CareerResource;
use App\Models\Career;
use App\Models\UserCareerGoal;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class CareerGoalController extends Controller
{
    public function store(StoreCareerGoalRequest $request): JsonResponse
    {
        $goal = DB::transaction(function () use ($request): UserCareerGoal {
            $user = $request->user();
            $careerId = (int) $request->validated('career_id');
            $previousCareerId = UserCareerGoal::where('user_id', $user->id)->value('career_id');
            $goal = UserCareerGoal::updateOrCreate(
                ['user_id' => $request->user()->id],
                ['career_id' => $careerId],
            );

            if ($previousCareerId !== null && (int) $previousCareerId !== $careerId) {
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
