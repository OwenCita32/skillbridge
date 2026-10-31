<?php

use App\Models\User;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Halaman Verifikasi Sertifikat & OpenGraph Preview (Untuk Logo & Media Sertifikat di LinkedIn)
Route::get('/verify/{id}', function (int $id) {
    $user = User::with('careerGoal.career')->find($id);
    $name = $user?->name ?? 'SkillBridge Certified Member';
    $career = $user?->careerGoal?->career?->title ?? 'Web Developer';
    $credId = 'SKB-2026-JR-' . str_pad((string) $id, 4, '0', STR_PAD_LEFT);
    $logoUrl = url('/images/skillbridge-logo.jpg');
    $pageTitle = "{$career} Job-Ready Certification — {$name} | SkillBridge";
    $description = "Sertifikat Kompetensi Digital resmi milik {$name} ({$credId}) yang diterbitkan dan diverifikasi oleh SkillBridge.";

    return response(<<<HTML
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{$pageTitle}</title>
    <meta name="description" content="{$description}">
    <meta property="og:type" content="website">
    <meta property="og:title" content="{$pageTitle}">
    <meta property="og:description" content="{$description}">
    <meta property="og:image" content="{$logoUrl}">
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="{$pageTitle}">
    <meta name="twitter:description" content="{$description}">
    <meta name="twitter:image" content="{$logoUrl}">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #F8FAFC; color: #0F172A; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; padding: 20px; }
        .card { background: #fff; max-width: 520px; width: 100%; border-radius: 24px; padding: 36px 28px; box-shadow: 0 20px 50px rgba(15, 23, 42, 0.08); text-align: center; border: 1px solid #E2E8F0; }
        .logo { width: 88px; height: 88px; object-fit: contain; border-radius: 20px; margin-bottom: 16px; border: 1px solid #E2E8F0; padding: 8px; background: #fff; }
        .badge { display: inline-block; background: #ECFDF5; color: #059669; font-weight: 700; font-size: 12px; padding: 6px 14px; border-radius: 99px; margin-bottom: 12px; }
        h1 { font-size: 22px; margin: 0 0 8px; }
        p { color: #64748B; font-size: 14px; line-height: 1.6; margin: 0 0 20px; }
        .meta { background: #F8FAFC; border-radius: 14px; padding: 14px; font-size: 13px; color: #334155; text-align: left; border: 1px solid #E2E8F0; }
        .meta div { margin-bottom: 6px; }
        .meta div:last-child { margin-bottom: 0; }
    </style>
</head>
<body>
    <div class="card">
        <img src="{$logoUrl}" alt="SkillBridge Logo" class="logo">
        <div><span class="badge">✓ Kredensial Terverifikasi SkillBridge</span></div>
        <h1>{$career} Job-Ready Certification</h1>
        <p>{$description}</p>
        <div class="meta">
            <div><strong>Pemilik Kredensial:</strong> {$name}</div>
            <div><strong>ID Kredensial:</strong> {$credId}</div>
            <div><strong>Penerbit:</strong> SkillBridge Industry Standard</div>
        </div>
    </div>
</body>
</html>
HTML, 200)->header('Content-Type', 'text/html; charset=UTF-8');
});

Route::get('/u/{id}', fn (int $id) => redirect("/verify/{$id}"));
