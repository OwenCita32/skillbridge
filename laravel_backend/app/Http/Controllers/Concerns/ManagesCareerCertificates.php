<?php

namespace App\Http\Controllers\Concerns;

use App\Models\PortfolioSubmission;
use App\Models\ProgressRecord;
use App\Services\SkillGapCalculator;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

trait ManagesCareerCertificates
{
    private function computeReadiness(array $skills): int
    {
        if (empty($skills)) {
            return 0;
        }

        $sumRatio = 0.0;
        $hasAnyAssessed = false;

        foreach ($skills as $s) {
            $cur = (float) ($s['current_level'] ?? 0);
            $tgt = (float) ($s['target_level'] ?? 3);
            if ($cur > 0) {
                $hasAnyAssessed = true;
            }
            $ratio = $tgt > 0 ? min(1.0, max(0.0, $cur / $tgt)) : 1.0;
            $sumRatio += $ratio;
        }

        if (!$hasAnyAssessed) {
            return 0;
        }

        return (int) round(($sumRatio / count($skills)) * 100);
    }

    public function certificates(Request $request, SkillGapCalculator $calculator): JsonResponse
    {
        $user = $request->user()->load('careerGoal.career');
        $careerTitle = $user->careerGoal?->career?->title ?? 'Web Developer';
        $analysis = $calculator->calculate($user);
        $skills = $analysis['skills'] ?? [];
        $readiness = $this->computeReadiness($skills);

        // Ambil daftar modul roadmap yang sudah diselesaikan (Jalur 2: Modul Portofolio / Roadmap Selesai)
        $completedRecords = ProgressRecord::query()
            ->where('user_id', $user->id)
            ->where('status', 'completed')
            ->with('roadmapItem.skill')
            ->orderByDesc('id')
            ->get();

        $completedBySkillId = [];
        foreach ($completedRecords as $rec) {
            $skillId = $rec->roadmapItem?->skill_id;
            if ($skillId !== null && !isset($completedBySkillId[$skillId])) {
                $completedBySkillId[$skillId] = $rec;
            }
        }

        // Ambil daftar tugas praktik portofolio yang sudah diserahkan (Jalur 2: Modul Portofolio Selesai)
        $portfolioSubmissions = PortfolioSubmission::query()
            ->where('user_id', $user->id)
            ->with('roadmapItem.skill')
            ->orderByDesc('id')
            ->get();

        $submittedBySkillId = [];
        foreach ($portfolioSubmissions as $sub) {
            $skillId = $sub->roadmapItem?->skill_id;
            if ($skillId !== null && !isset($submittedBySkillId[$skillId])) {
                $submittedBySkillId[$skillId] = $sub;
            }
        }

        $certs = [];
        $idxCounter = 1;

        // 1. Evaluasi per Skill dari Target Karier (Jalur 1: Evaluasi Gap Skill >= 80% & Jalur 2: Modul Selesai)
        foreach ($skills as $s) {
            $skillModel = $s['skill'];
            $skillId = (int) $skillModel->id;
            $skillName = (string) $skillModel->name;
            $cur = (float) ($s['current_level'] ?? 0);
            $tgt = (float) ($s['target_level'] ?? 4);
            $pct = $tgt > 0 ? (int) round(min(1.0, max(0.0, $cur / $tgt)) * 100) : 0;

            $isEvalPassed = $pct >= 80;
            $completedRec = $completedBySkillId[$skillId] ?? null;
            $portfolioSub = $submittedBySkillId[$skillId] ?? null;
            $isModuleDone = $completedRec !== null || $portfolioSub !== null;

            $isEarned = $isEvalPassed || $isModuleDone;

            if ($isEvalPassed && $isModuleDone) {
                $category = 'Evaluasi ≥ 80% & Modul Selesai';
                $sourceBadge = 'Jalur 1 & 2 Terpenuhi';
                $criteria = "Lulus evaluasi kompetensi ({$pct}%) dan menuntaskan modul praktik {$skillName}.";
                $scoreLabel = "{$pct}% (Lulus)";
            } elseif ($isEvalPassed) {
                $category = 'Jalur 1 · Evaluasi Gap Skill ≥ 80%';
                $sourceBadge = 'Evaluasi Skill ≥ 80%';
                $criteria = "Diterbitkan karena hasil evaluasi skill {$skillName} mencapai {$pct}% (standar klien ≥ 80%).";
                $scoreLabel = "{$pct}%";
            } elseif ($isModuleDone) {
                $category = 'Jalur 2 · Modul Portofolio Selesai';
                $sourceBadge = 'Modul Roadmap Selesai';
                $criteria = "Diterbitkan karena berhasil menyelesaikan modul pembelajaran & praktik {$skillName} pada roadmap.";
                $scoreLabel = $pct > 0 ? "Modul Selesai ({$pct}%)" : '100% Selesai';
            } else {
                $category = 'Menunggu Verifikasi (Target ≥ 80%)';
                $sourceBadge = 'Belum Aktif';
                $criteria = "Capai skor evaluasi ≥ 80% (saat ini {$pct}%) atau selesaikan modul {$skillName} di Roadmap untuk mengaktifkan sertifikat ini.";
                $scoreLabel = "Progres {$pct}%";
            }

            $issueDate = $completedRec?->created_at?->translatedFormat('M Y')
                ?? $portfolioSub?->created_at?->translatedFormat('M Y')
                ?? now()->translatedFormat('M Y');

            $certs[] = [
                'id' => $idxCounter,
                'skill_id' => $skillId,
                'skill_name' => $skillName,
                'title' => "Sertifikat Kompetensi: {$skillName}",
                'category' => $category,
                'source_badge' => $sourceBadge,
                'issuer' => 'SkillBridge Assessment & Lab',
                'credential_id' => sprintf('SKB-2026-SK-%02d%02d', $user->id, $skillId),
                'issue_date' => $isEarned ? $issueDate : 'Belum Terbit',
                'score' => $scoreLabel,
                'progress_pct' => $pct,
                'is_earned' => $isEarned,
                'status' => $isEarned ? 'Terverifikasi Otomatis' : 'Belum Aktif',
                'criteria' => $criteria,
                'skills' => [$skillName, $careerTitle, $isEarned ? 'Terverifikasi' : "Target ≥ 80%"],
            ];
            $idxCounter++;
        }

        // 2. Sertifikat Utama Kesiapan Karier ([Karier] Job-Ready Certification)
        $allModulesDone = count($skills) > 0 && count($completedBySkillId) >= count($skills);
        $isCareerReady = $readiness >= 80 || $allModulesDone;

        $careerCert = [
            'id' => $idxCounter,
            'skill_id' => null,
            'skill_name' => $careerTitle,
            'title' => "{$careerTitle} Job-Ready Certification",
            'category' => $isCareerReady
                ? 'Jalur 1 & 2 · Sertifikasi Kesiapan Kerja Utama'
                : 'Sertifikasi Utama Karier (Target ≥ 80%)',
            'source_badge' => $isCareerReady ? 'Job-Ready Verified' : 'Progres Kesiapan',
            'issuer' => 'SkillBridge Industry Standard',
            'credential_id' => 'SKB-2026-JR-' . str_pad((string) $user->id, 4, '0', STR_PAD_LEFT),
            'issue_date' => $isCareerReady ? now()->translatedFormat('M Y') : 'Belum Terbit',
            'score' => "{$readiness}%",
            'progress_pct' => $readiness,
            'is_earned' => $isCareerReady,
            'status' => $isCareerReady ? 'Terverifikasi Otomatis' : 'Belum Aktif',
            'criteria' => $isCareerReady
                ? "Telah memenuhi standar kesiapan kerja industri ({$readiness}%) dan menuntaskan kurikulum {$careerTitle}."
                : "Diterbitkan otomatis saat rata-rata evaluasi skill {$careerTitle} mencapai ≥ 80% (saat ini {$readiness}%) atau seluruh modul roadmap selesai.",
            'skills' => [$careerTitle, 'Standar Klien ≥ 80%', 'Portofolio Terverifikasi'],
        ];

        // Urutkan agar sertifikat yang sudah aktif (is_earned = true) tampil di atas
        array_unshift($certs, $careerCert);
        usort($certs, fn (array $a, array $b): int => ($b['is_earned'] <=> $a['is_earned']));

        $earnedCount = count(array_filter($certs, fn (array $c): bool => (bool) $c['is_earned']));

        return ApiResponse::success([
            'total' => $earnedCount,
            'total_all' => count($certs),
            'readiness_score' => $readiness,
            'certificates' => $certs,
            'source_explanation' => 'Sertifikat diterbitkan otomatis melalui 2 jalur: (1) Evaluasi Gap Skill mencapai standar klien ≥ 80%, atau (2) Penyelesaian modul & tugas portofolio pada Roadmap.',
        ], 'Sertifikat kompetensi berhasil dimuat.');
    }
}

