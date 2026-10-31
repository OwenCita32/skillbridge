<?php

use App\Http\Controllers\AssessmentController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CareerController;
use App\Http\Controllers\CareerGoalController;
use App\Http\Controllers\LearningResourceController;
use App\Http\Controllers\RoadmapController;
use App\Http\Controllers\RoadmapItemProgressController;
use App\Http\Controllers\SkillController;
use App\Http\Controllers\SkillGapController;
use App\Http\Controllers\SkillGapExplanationController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function (): void {
    Route::middleware('throttle:auth')->group(function (): void {
        Route::post('/register', [AuthController::class, 'register']);
        Route::post('/login', [AuthController::class, 'login']);
    });

    Route::get('/careers', [CareerController::class, 'index']);
    Route::get('/careers/{career}', [CareerController::class, 'show']);
    Route::get('/skills', [SkillController::class, 'index']);
    Route::get('/resources', [LearningResourceController::class, 'index']);

    Route::middleware('auth:sanctum')->group(function (): void {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::post('/career-goals', [CareerGoalController::class, 'store']);
        Route::post('/assessments', [AssessmentController::class, 'store']);
        Route::get('/assessments/{assessment}', [AssessmentController::class, 'show']);
        Route::get('/skill-gaps', [SkillGapController::class, 'index']);
        Route::post('/skill-gaps/explanation', [SkillGapExplanationController::class, 'store'])->middleware('throttle:ai');
        Route::post('/roadmaps/generate', [RoadmapController::class, 'generate'])->middleware('throttle:roadmaps');
        Route::get('/roadmaps/current', [RoadmapController::class, 'current']);
        Route::patch('/roadmap-items/{item}/progress', [RoadmapItemProgressController::class, 'update']);
    });
});
