<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class AiMentorService
{
    public function __construct(
        private readonly SkillGapCalculator $skillGapCalculator,
        private readonly OpenAiResponsesClient $openAiClient,
    ) {}

    /**
     * @param  list<array{role: string, content: string}>  $history
     * @return array{reply: string, source: string, model: string}
     */
    public function chat(User $user, string $userMessage, array $history = []): array
    {
        $analysis = $this->skillGapCalculator->calculate($user);
        $careerTitle = $analysis !== null && $analysis['career'] !== null
            ? (string) $analysis['career']->title
            : 'Freelance Professional';

        $readinessScore = $analysis !== null
            ? (int) ($analysis['readiness_score'] ?? 52)
            : 52;

        $skillGaps = $analysis !== null
            ? ($analysis['skills'] ?? [])
            : [];

        // Format summary kesenjangan skill
        $skillsSummaryLines = [];
        foreach ($skillGaps as $item) {
            $name = $item['skill']->name ?? 'Skill';
            $gap = $item['gap'] ?? 0;
            $pct = $item['percentage'] ?? 0;
            $skillsSummaryLines[] = "- {$name}: Skor {$pct}%, Gap {$gap}";
        }
        $skillsSummary = implode("\n", $skillsSummaryLines);

        $systemPrompt = "Kamu adalah SkillBridge AI Career Mentor. Tugasmu adalah memberikan bimbingan, strategi, dan saran karier freelance yang taktis, ramah, dan profesional bagi pengguna.\n"
            . "Konteks Pengguna:\n"
            . "- Target Karier: {$careerTitle}\n"
            . "- Skor Kesiapan Kerja Saat Ini: {$readinessScore}% (Standar Industri: 80%)\n"
            . "- Status Kesenjangan Skill:\n{$skillsSummary}\n\n"
            . "Panduan Menjawab:\n"
            . "1. Jawab langsung to-the-point dalam bahasa Indonesia yang suportif dan profesional (gaya mentor freelance berpengalaman).\n"
            . "2. Berikan 3-4 langkah aksi konkret yang bisa langsung dipraktikkan (actionable next steps).\n"
            . "3. Berikan insight industri nyata (seperti rate freelance, platform Upwork/Fiverr/Fastwork, atau standar portofolio).\n"
            . "4. Format jawaban dengan rapi menggunakan bullet points atau numbering tebal.";

        // Coba panggil OpenAI jika API Key tersedia
        $apiKeys = $this->openAiClient->apiKeys();
        if (!empty($apiKeys) && config('services.openai.enabled', true)) {
            $model = (string) config('services.openai.model', 'gpt-4o-mini');
            $baseUrl = rtrim((string) config('services.openai.base_url', 'https://api.openai.com/v1'), '/');

            // Format percakapan untuk chat completions
            $messages = [
                ['role' => 'system', 'content' => $systemPrompt],
            ];

            foreach (array_slice($history, -4) as $msg) {
                if (isset($msg['role'], $msg['content'])) {
                    $messages[] = [
                        'role' => $msg['role'] === 'user' ? 'user' : 'assistant',
                        'content' => (string) $msg['content'],
                    ];
                }
            }

            $messages[] = ['role' => 'user', 'content' => $userMessage];

            foreach ($apiKeys as $apiKey) {
                try {
                    $response = Http::acceptJson()
                        ->asJson()
                        ->withToken($apiKey)
                        ->timeout((int) config('services.openai.timeout', 20))
                        ->connectTimeout((int) config('services.openai.connect_timeout', 5))
                        ->post("{$baseUrl}/chat/completions", [
                            'model' => $model,
                            'messages' => $messages,
                            'max_tokens' => 650,
                            'temperature' => 0.7,
                        ]);

                    if ($response->successful()) {
                        $reply = (string) ($response->json('choices.0.message.content') ?? '');
                        if (trim($reply) !== '') {
                            return [
                                'reply' => trim($reply),
                                'source' => 'openai',
                                'model' => $model,
                            ];
                        }
                    }
                } catch (\Throwable $e) {
                    Log::warning('OpenAI Mentor Chat exception, fallback active: ' . $e->getMessage());
                }
            }
        }

        // Fallback cerdas berbasis konteks user
        $fallbackReply = $this->generateFallbackReply($userMessage, $careerTitle, $readinessScore, $skillGaps);

        return [
            'reply' => $fallbackReply,
            'source' => 'fallback',
            'model' => 'SkillBridge Hybrid Engine',
        ];
    }

    /**
     * @param  list<array<string, mixed>>  $skillGaps
     */
    private function generateFallbackReply(
        string $message,
        string $careerTitle,
        int $readinessScore,
        array $skillGaps,
    ): string {
        $lower = strtolower($message);

        // Cari skill dengan gap tertinggi
        $highestGapSkill = 'Dasar & Teori ' . $careerTitle;
        $maxGap = 0;
        foreach ($skillGaps as $item) {
            $g = (int) ($item['gap'] ?? 0);
            if ($g > $maxGap) {
                $maxGap = $g;
                $highestGapSkill = (string) ($item['skill']->name ?? $highestGapSkill);
            }
        }

        if (str_contains($lower, 'rate') || str_contains($lower, 'tarif') || str_contains($lower, 'gaji') || str_contains($lower, 'harga')) {
            return "Halo! Dengan tingkat kesiapan kamu saat ini di **{$readinessScore}%** untuk peran **{$careerTitle}**, berikut panduan tarif freelance realistis yang bisa kamu pasang:\n\n"
                . "1. **Tarif Per Jam (Hourly):**\n"
                . "   - Klien Lokal: **Rp 100.000 – Rp 200.000 / jam**.\n"
                . "   - Klien Internasional (Upwork/Fiverr): **\$12 – \$18 / jam** untuk tahap membangun reputasi awal.\n\n"
                . "2. **Tarif Per Proyek (Fixed Price):**\n"
                . "   - Proyek mini/landing page: **Rp 1.500.000 – Rp 3.000.000**.\n"
                . "   - Proyek kustom multi-halaman: **Rp 3.500.000 – Rp 7.000.000**.\n\n"
                . "💡 **Tips Mentor:** Setelah kamu mendapatkan 3 review bintang 5 pertama, naikkan tarifmu sebesar 20-30% secara berkala!";
        }

        if (str_contains($lower, 'gap') || str_contains($lower, 'tutup') || str_contains($lower, 'cepat') || str_contains($lower, 'belajar')) {
            return "Untuk mengejar standar klien freelance (minimal 80%) dari posisimu saat ini (**{$readinessScore}%**), fokus utamamu ada pada **{$highestGapSkill}**.\n\n"
                . "Berikut rencana aksi 14 hari yang terbukti efektif:\n"
                . "1. **Hari 1–4 (Fondasi):** Tonton video konsep inti di menu Roadmap dan rangkum poin kunci dalam catatan teknismu.\n"
                . "2. **Hari 5–8 (Praktik Nyata):** Jangan hanya membaca! Buat 1 replika komponen nyata dan upload ke GitHub atau live preview.\n"
                . "3. **Hari 9–11 (Kuis & Evaluasi):** Selesaikan kuis pemahaman di SkillBridge untuk menaikkan skor kesiapanmu secara langsung di sistem.\n"
                . "4. **Hari 12–14 (Dokumentasi):** Tulis ringkasan solusi yang kamu selesaikan sebagai bahan studi kasus portofolio.";
        }

        if (str_contains($lower, 'portofolio') || str_contains($lower, 'portfolio') || str_contains($lower, 'karya')) {
            return "Klien freelance modern tidak hanya melihat tampilan visual, tapi **kemampuan menyelesaikan masalah (Problem Solving)**. Untuk peran **{$careerTitle}**, susun portofoliomu dengan format ini:\n\n"
                . "1. **The Problem:** Apa tantangan bisnis atau masalah pengguna yang ingin diselesaikan?\n"
                . "2. **The Process:** Jelaskan peranmu, alur kerja (workflow), serta alat yang kamu gunakan.\n"
                . "3. **The Solution:** Tampilkan hasil akhir karya dengan screenshot beresolusi tinggi atau link live preview aktif.\n"
                . "4. **The Impact:** Jika ada, sebutkan dampak (misal: 'meningkatkan kecepatan loading 40%' atau 'memudahkan user onboarding').\n\n"
                . "💡 Kamu bisa submit hasil praktik portofolio langsung lewat menu **Praktik Portofolio** di roadmap!";
        }

        if (str_contains($lower, 'klien') || str_contains($lower, 'upwork') || str_contains($lower, 'fiverr') || str_contains($lower, 'cari')) {
            return "Mendapatkan klien freelance pertama membutuhkan strategi channel yang tepat untuk posisi **{$careerTitle}**:\n\n"
                . "1. **Platform Freelance Global (Upwork / Freelancer):**\n"
                . "   - Tulis proposal yang personal (hindari template copy-paste). Bahas masalah klien di 2 baris pertama proposal.\n\n"
                . "2. **Platform Mikro (Fiverr / Fastwork):**\n"
                . "   - Buat Gig/Layanan yang sangat spesifik (misal: 'Saya buatkan responsive landing page dalam 3 hari').\n\n"
                . "3. **Networking Aktif (LinkedIn & Komunitas):**\n"
                . "   - Bagikan proses belajarmu secara publik (Building in public). Seringkali klien datang dari postingan studi kasus yang kita bagikan!";
        }

        // Jawaban konsultasi umum
        return "Pertanyaan yang sangat bagus untuk persiapan kariermu sebagai **{$careerTitle}**!\n\n"
            . "Dengan skor kesiapan **{$readinessScore}%**, kamu sudah berada di jalur yang tepat. Kunci utama untuk menarik minat klien adalah membuktikan bahwa kamu menguasai alur kerja nyata dan mampu mengeksekusi deliverable tepat waktu.\n\n"
            . "Rekomendasi prioritas hari ini:\n"
            . "- Selesaikan latihan pada skill **{$highestGapSkill}**.\n"
            . "- Uji pemahamanmu lewat kuis assessment berkala agar tingkat kesiapanmu naik menuju 80%.\n"
            . "- Catat setiap progres lamaranmu di menu Tracker Lamaran agar pencarian proyekmu terorganisir!\n\n"
            . "Ada hal spesifik lain seputar teknis, proposal, atau klien yang ingin kamu diskusikan?";
    }
}

