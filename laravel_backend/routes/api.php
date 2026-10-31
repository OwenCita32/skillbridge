<?php

use App\Http\Controllers\AssessmentController;
use App\Http\Controllers\AiMentorController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CareerController;
use App\Http\Controllers\CareerGoalController;
use App\Http\Controllers\JobApplicationController;
use App\Http\Controllers\LearningResourceController;
use App\Http\Controllers\PortfolioSubmissionController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\QuizController;
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
        Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
        Route::post('/reset-password', [AuthController::class, 'resetPassword']);
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

        // Job Tracker API
        Route::get('/job-applications', [JobApplicationController::class, 'index']);
        Route::post('/job-applications', [JobApplicationController::class, 'store']);
        Route::patch('/job-applications/{jobApplication}/status', [JobApplicationController::class, 'updateStatus']);
        Route::delete('/job-applications/{jobApplication}', [JobApplicationController::class, 'destroy']);

        // Portfolio Practice Submissions
        Route::post('/portfolio-submissions', [PortfolioSubmissionController::class, 'store']);

        // Quiz score submit & skill gap auto-updater
        Route::post('/quizzes/submit', [QuizController::class, 'submit']);

        // AI Career Mentor Chat
        Route::post('/mentor/chat', [AiMentorController::class, 'chat']);

        // Profile & Portfolio Integration
        Route::get('/profile', [ProfileController::class, 'show']);
        Route::patch('/profile', [ProfileController::class, 'update']);
        Route::post('/profile/github-import', [ProfileController::class, 'importGithub']);
        Route::get('/profile/linkedin-export', [ProfileController::class, 'linkedinExport']);
        Route::get('/profile/certificates', [ProfileController::class, 'certificates']);
    });
});
