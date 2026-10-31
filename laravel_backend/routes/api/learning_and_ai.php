<?php

use App\Http\Controllers\AiMentorController;
use App\Http\Controllers\AssessmentController;
use App\Http\Controllers\CareerGoalController;
use App\Http\Controllers\PortfolioSubmissionController;
use App\Http\Controllers\QuizController;
use App\Http\Controllers\RoadmapController;
use App\Http\Controllers\RoadmapItemProgressController;
use App\Http\Controllers\SkillGapController;
use App\Http\Controllers\SkillGapExplanationController;
use Illuminate\Support\Facades\Route;

Route::middleware('auth:sanctum')->group(function (): void {
    // Career Goals & Skill Assessments
    Route::post('/career-goals', [CareerGoalController::class, 'store']);
    Route::post('/assessments', [AssessmentController::class, 'store']);
    Route::get('/assessments/{assessment}', [AssessmentController::class, 'show']);
    Route::get('/skill-gaps', [SkillGapController::class, 'index']);
    Route::post('/skill-gaps/explanation', [SkillGapExplanationController::class, 'store'])->middleware('throttle:ai');

    // Personalized Learning Roadmap
    Route::post('/roadmaps/generate', [RoadmapController::class, 'generate'])->middleware('throttle:roadmaps');
    Route::get('/roadmaps/current', [RoadmapController::class, 'current']);
    Route::patch('/roadmap-items/{item}/progress', [RoadmapItemProgressController::class, 'update']);

    // Portfolio Practice Submissions & Skill Quizzes
    Route::post('/portfolio-submissions', [PortfolioSubmissionController::class, 'store']);
    Route::post('/quizzes/submit', [QuizController::class, 'submit']);

    // AI Career Mentor Chat
    Route::post('/mentor/chat', [AiMentorController::class, 'chat']);
});

