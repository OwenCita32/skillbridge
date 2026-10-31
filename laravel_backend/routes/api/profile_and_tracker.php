<?php

use App\Http\Controllers\JobApplicationController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\ProfileController;
use Illuminate\Support\Facades\Route;

Route::middleware('auth:sanctum')->group(function (): void {
    // Job Application Tracker
    Route::get('/job-applications', [JobApplicationController::class, 'index']);
    Route::post('/job-applications', [JobApplicationController::class, 'store']);
    Route::patch('/job-applications/{jobApplication}/status', [JobApplicationController::class, 'updateStatus']);
    Route::delete('/job-applications/{jobApplication}', [JobApplicationController::class, 'destroy']);

    // Profile, GitHub/LinkedIn Portfolio & Certificates
    Route::get('/profile', [ProfileController::class, 'show']);
    Route::patch('/profile', [ProfileController::class, 'update']);
    Route::post('/profile/github-import', [ProfileController::class, 'importGithub']);
    Route::get('/profile/linkedin-export', [ProfileController::class, 'linkedinExport']);
    Route::get('/profile/certificates', [ProfileController::class, 'certificates']);

    // Self-Hosted In-App Notifications
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::patch('/notifications/{notification}/read', [NotificationController::class, 'markAsRead']);
    Route::post('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);
    Route::delete('/notifications/{notification}', [NotificationController::class, 'destroy']);
});

