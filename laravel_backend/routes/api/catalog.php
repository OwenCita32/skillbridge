<?php

use App\Http\Controllers\CareerController;
use App\Http\Controllers\LearningResourceController;
use App\Http\Controllers\SkillController;
use Illuminate\Support\Facades\Route;

// Public Catalog Routes (Careers, Skills, Learning Resources)
Route::get('/careers', [CareerController::class, 'index']);
Route::get('/careers/{career}', [CareerController::class, 'show']);
Route::get('/skills', [SkillController::class, 'index']);
Route::get('/resources', [LearningResourceController::class, 'index']);

