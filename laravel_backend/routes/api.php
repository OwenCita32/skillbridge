<?php

use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function (): void {
    require __DIR__ . '/api/auth.php';
    require __DIR__ . '/api/catalog.php';
    require __DIR__ . '/api/learning_and_ai.php';
    require __DIR__ . '/api/profile_and_tracker.php';
});
