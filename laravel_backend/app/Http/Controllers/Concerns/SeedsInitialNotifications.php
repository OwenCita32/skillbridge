<?php

namespace App\Http\Controllers\Concerns;

use App\Models\UserNotification;

trait SeedsInitialNotifications
{
    private function seedInitialNotifications($user): void
    {
        $career = $user->careerGoal?->career?->title ?? 'Web Developer';
        $githubCount = is_array($user->github_repos) ? count($user->github_repos) : 0;

        $items = [
            [
                'title' => 'Target Karier Aktif 🎯',
                'message' => "Selamat datang di SkillBridge! Fokus target kariermu diset ke {$career}. Mulai langkah belajarmu hari ini.",
                'type' => 'roadmap',
                'action_type' => 'roadmap',
                'created_at' => now()->subHours(5),
            ],
            [
                'title' => 'Bukti Sertifikat Digital 🏅',
                'message' => 'Sertifikat kompetensi kamu telah diperbarui berdasarkan evaluasi skill target dan kesiapan industri.',
                'type' => 'certificate',
                'action_type' => 'certificates',
                'created_at' => now()->subHours(3),
            ],
            [
                'title' => 'Asah Skill dengan Kuis ⚡',
                'message' => 'Kerjakan kuis kompetensi untuk memvalidasi pemahaman teknismu dan tingkatkan skor verifikasi.',
                'type' => 'quiz',
                'action_type' => 'quiz',
                'created_at' => now()->subHour(),
            ],
        ];

        if ($githubCount > 0) {
            $items[] = [
                'title' => 'Portofolio GitHub Terhubung 🐙',
                'message' => "{$githubCount} repositori publik dari @{$user->github_username} berhasil disinkronkan ke profilmu.",
                'type' => 'github',
                'action_type' => 'profile',
                'created_at' => now()->subMinutes(25),
            ];
        }

        $items[] = [
            'title' => 'Kelola Lamaran Kerja 📋',
            'message' => 'Pantau status interview dan pengajuan magang / pekerjaan impianmu di Application Tracker.',
            'type' => 'tracker',
            'action_type' => 'tracker',
            'created_at' => now()->subMinutes(10),
        ];

        foreach ($items as $item) {
            UserNotification::create([
                'user_id' => $user->id,
                'title' => $item['title'],
                'message' => $item['message'],
                'type' => $item['type'],
                'action_type' => $item['action_type'],
                'action_payload' => null,
                'read_at' => null,
                'created_at' => $item['created_at'],
                'updated_at' => $item['created_at'],
            ]);
        }
    }
}

