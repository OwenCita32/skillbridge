<?php

namespace App\Services;

use App\Exceptions\OpenAiResponseException;
use App\Models\Career;
use App\Models\CareerSkillRequirement;
use App\Models\Skill;
use Illuminate\Support\Str;

class CustomCareerService
{
    public function __construct(
        private readonly OpenAiResponsesClient $openAiClient,
    ) {}

    public function resolveOrCreate(string $title): Career
    {
        $cleanTitle = trim($title);
        $slug = Str::slug($cleanTitle);

        if ($slug === '') {
            $slug = 'custom-career-' . Str::random(6);
        }

        // 1. Cek apakah sudah ada karier yang sama persis atau mirip di database (0 token)
        $existing = Career::where('slug', $slug)
            ->orWhere('title', 'like', $cleanTitle)
            ->first();

        if ($existing !== null) {
            return $existing;
        }

        // 2. Jika belum ada, panggil AI 1 kali saja untuk mengidentifikasi 4 skill esensial peran ini
        $skillsData = $this->generateSkillsWithAi($cleanTitle);

        $career = Career::create([
            'slug' => $slug,
            'title' => $cleanTitle,
            'summary' => "Target karier khusus untuk {$cleanTitle}.",
            'description' => "Jalur kompetensi yang dipetakan khusus untuk peran {$cleanTitle}.",
            'is_demo' => false,
        ]);

        foreach ($skillsData as $item) {
            $skillSlug = Str::slug($career->slug . '-' . $item['name']);
            if ($skillSlug === '') {
                $skillSlug = 'skill-' . Str::random(6);
            }

            $skill = Skill::firstOrCreate(
                ['slug' => $skillSlug],
                [
                    'name' => $item['name'],
                    'description' => $item['description'],
                    'category' => $item['category'] ?? 'core',
                    'is_demo' => false,
                ]
            );

            CareerSkillRequirement::firstOrCreate(
                [
                    'career_id' => $career->id,
                    'skill_id' => $skill->id,
                ],
                [
                    'target_level' => $item['target_level'] ?? 4,
                ]
            );
        }

        return $career;
    }

    /**
     * @return list<array{name: string, description: string, category: string, target_level: int}>
     */
    private function generateSkillsWithAi(string $title): array
    {
        try {
            $schema = [
                'type' => 'object',
                'properties' => [
                    'skills' => [
                        'type' => 'array',
                        'items' => [
                            'type' => 'object',
                            'properties' => [
                                'name' => ['type' => 'string'],
                                'description' => ['type' => 'string'],
                                'category' => ['type' => 'string'],
                                'target_level' => ['type' => 'integer'],
                            ],
                            'required' => ['name', 'description', 'category', 'target_level'],
                            'additionalProperties' => false,
                        ],
                    ],
                ],
                'required' => ['skills'],
                'additionalProperties' => false,
            ];

            $response = $this->openAiClient->createStructuredResponse(
                'custom_career_skills',
                $schema,
                "Identifikasi 4 skill esensial yang paling dibutuhkan untuk peran pekerjaan '{$title}'. Berikan nama skill, deskripsi ringkas dalam bahasa Indonesia, kategori, dan target level (antara 3 sampai 4).",
                ['career_title' => $title],
                500,
            );

            if (!empty($response['skills']) && is_array($response['skills'])) {
                $validated = [];
                foreach ($response['skills'] as $skill) {
                    if (is_array($skill) && isset($skill['name'], $skill['description'])) {
                        $validated[] = [
                            'name' => (string) $skill['name'],
                            'description' => (string) $skill['description'],
                            'category' => (string) ($skill['category'] ?? 'core'),
                            'target_level' => max(1, min(5, (int) ($skill['target_level'] ?? 4))),
                        ];
                    }
                }
                if (count($validated) >= 3) {
                    return $validated;
                }
            }
        } catch (OpenAiResponseException) {
            // Fallback deterministik jika AI offline atau rate limit
        }

        return [
            [
                'name' => "Dasar & Teori {$title}",
                'description' => "Fondasi konsep, standar industri, dan metodologi kerja untuk {$title}.",
                'category' => 'foundations',
                'target_level' => 4,
            ],
            [
                'name' => "Alat & Alur Kerja {$title}",
                'description' => "Kemampuan teknis menggunakan tool standar dan alur kerja utama peran {$title}.",
                'category' => 'tools_and_workflow',
                'target_level' => 4,
            ],
            [
                'name' => "Portofolio & Proyek Nyata",
                'description' => "Studi kasus nyata dan bukti kemampuan hasil karya untuk peran {$title}.",
                'category' => 'portfolio',
                'target_level' => 3,
            ],
            [
                'name' => "Komunikasi & Kesiapan Klien",
                'description' => "Kemampuan presentasi, kolaborasi profesional, dan penawaran ke klien freelance.",
                'category' => 'communication',
                'target_level' => 3,
            ],
        ];
    }
}

