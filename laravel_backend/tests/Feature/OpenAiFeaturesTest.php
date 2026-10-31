<?php

namespace Tests\Feature;

use App\Models\Career;
use App\Models\LearningResource;
use App\Models\User;
use Database\Seeders\SkillBridgeDemoSeeder;
use Illuminate\Foundation\Testing\LazilyRefreshDatabase;
use Illuminate\Http\Client\Request as HttpRequest;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class OpenAiFeaturesTest extends TestCase
{
    use LazilyRefreshDatabase;

    public function test_skill_gap_explanation_does_not_change_backend_scores(): void
    {
        $before = $this->prepareAssessedGaps();
        $output = [
            'explanations' => collect($before)->map(fn (array $gap): array => [
                'skill_id' => $gap['skill_id'],
                'explanation' => 'Kompetensi ini membantu memahami pola kerja keamanan yang relevan.',
                'suggested_next_action' => 'Pelajari materi terkurasi lalu catat hasil latihanmu.',
            ])->all(),
        ];
        $this->fakeOpenAi($output);

        $response = $this->postJson('/api/v1/skill-gaps/explanation');

        $response->assertOk()
            ->assertJsonPath('data.explanation_source', 'openai_responses')
            ->assertJsonPath('data.model', 'gpt-6-luna');
        $this->assertStringNotContainsString('test-openai-key', json_encode($response->json()));
        $this->assertSame($before, $this->snapshot($this->getJson('/api/v1/skill-gaps')->json('data.skills')));
        Http::assertSent(fn (HttpRequest $request): bool => $request->url() === 'https://api.openai.com/v1/responses'
            && $request->data()['model'] === 'gpt-6-luna'
            && ! str_contains($request->data()['input'], 'learner@example.test'));
    }

    public function test_personalized_roadmap_only_links_catalog_resources_and_preserves_gaps(): void
    {
        $before = $this->prepareAssessedGaps();
        $this->fakeOpenAi([
            'summary' => 'Roadmap menyusun latihan dari kompetensi yang perlu perhatian.',
            'priorities' => $this->priorities($before),
        ]);

        $response = $this->postJson('/api/v1/roadmaps/generate');

        $response->assertCreated()
            ->assertJsonPath('data.generation_mode', 'openai_responses')
            ->assertJsonPath('data.generation_model', 'gpt-6-luna');
        $catalogIds = LearningResource::query()
            ->where('is_active', true)
            ->whereNotNull('verified_at')
            ->pluck('id')
            ->map(fn ($id): int => (int) $id)
            ->all();
        foreach ($response->json('data.items') as $item) {
            foreach ($item['resources'] as $resource) {
                $this->assertContains((int) $resource['id'], $catalogIds);
                $this->assertDatabaseHas('learning_resource_roadmap_item', [
                    'roadmap_item_id' => $item['id'],
                    'learning_resource_id' => $resource['id'],
                ]);
            }
        }
        $this->assertSame($before, $this->snapshot($this->getJson('/api/v1/skill-gaps')->json('data.skills')));
    }

    public function test_unknown_resource_id_is_rejected_and_uses_fallback(): void
    {
        $gaps = $this->prepareAssessedGaps();
        $priorities = $this->priorities($gaps);
        $priorities[0]['tasks'][0]['resource_ids'] = [999999];
        $this->fakeOpenAi([
            'summary' => 'Roadmap latihan bertahap untuk kompetensi yang dipilih.',
            'priorities' => $priorities,
        ]);

        $response = $this->postJson('/api/v1/roadmaps/generate');

        $response->assertCreated()->assertJsonPath('data.generation_mode', 'deterministic_fallback');
        $this->assertDatabaseMissing('learning_resource_roadmap_item', ['learning_resource_id' => 999999]);
        foreach ($response->json('data.items') as $item) {
            foreach ($item['resources'] as $resource) {
                $this->assertDatabaseHas('learning_resources', ['id' => $resource['id'], 'is_active' => true]);
            }
        }
    }

    public function test_rate_limit_falls_back_to_deterministic_explanation(): void
    {
        $this->prepareAssessedGaps();
        $this->configureOpenAi();
        Http::preventStrayRequests();
        Http::fake(['https://api.openai.com/v1/responses' => Http::response(['error' => ['message' => 'limited']], 429)]);

        $response = $this->postJson('/api/v1/skill-gaps/explanation');

        $response->assertOk()
            ->assertJsonPath('data.explanation_source', 'deterministic_fallback')
            ->assertJsonPath('data.fallback_reason', 'rate_limit');
        $this->assertNotEmpty($response->json('data.skills.0.explanation'));
    }

    public function test_model_output_cannot_add_or_change_skill_gap_values(): void
    {
        $before = $this->prepareAssessedGaps();
        $output = [
            'explanations' => collect($before)->map(fn (array $gap): array => [
                'skill_id' => $gap['skill_id'],
                'explanation' => 'Kompetensi ini membantu memahami pola kerja yang relevan.',
                'suggested_next_action' => 'Pelajari materi terkurasi lalu catat hasil latihanmu.',
            ])->all(),
        ];
        $output['explanations'][0]['gap'] = 0;
        $this->fakeOpenAi($output);

        $response = $this->postJson('/api/v1/skill-gaps/explanation');

        $response->assertOk()
            ->assertJsonPath('data.explanation_source', 'deterministic_fallback')
            ->assertJsonPath('data.fallback_reason', 'invalid_response');
        $this->assertSame($before, $this->snapshot($this->getJson('/api/v1/skill-gaps')->json('data.skills')));
    }

    public function test_invalid_provider_key_falls_back_for_roadmap_without_leaking_provider_details(): void
    {
        $this->prepareAssessedGaps();
        $this->configureOpenAi();
        Http::preventStrayRequests();
        Http::fake([
            'https://api.openai.com/v1/responses' => Http::response([
                'error' => ['message' => 'provider echoed sensitive upstream details'],
            ], 401),
        ]);

        $response = $this->postJson('/api/v1/roadmaps/generate');

        $response->assertCreated()
            ->assertJsonPath('data.generation_mode', 'deterministic_fallback')
            ->assertJsonPath('data.generation_model', null);
        $this->assertStringNotContainsString('sensitive upstream details', json_encode($response->json()));
        $this->assertStringNotContainsString('test-openai-key', json_encode($response->json()));
    }

    /** @return list<array{skill_id: int, current_level: ?int, target_level: int, gap: ?int, is_assessed: bool}> */
    private function prepareAssessedGaps(): array
    {
        $this->seed(SkillBridgeDemoSeeder::class);
        $career = Career::where('slug', 'cybersecurity-analyst')->firstOrFail();
        Sanctum::actingAs(User::factory()->create(['email' => 'learner@example.test']));
        $this->postJson('/api/v1/career-goals', ['career_id' => $career->id])->assertOk();
        $answers = $career->skillRequirements()->orderBy('skill_id')->get()
            ->map(fn ($requirement): array => ['skill_id' => (int) $requirement->skill_id, 'level' => 0])
            ->all();
        $this->postJson('/api/v1/assessments', ['answers' => $answers])->assertCreated();

        return $this->snapshot($this->getJson('/api/v1/skill-gaps')->assertOk()->json('data.skills'));
    }

    /** @param list<array<string, mixed>> $skills
     * @return list<array{skill_id: int, current_level: ?int, target_level: int, gap: ?int, is_assessed: bool}>
     */
    private function snapshot(array $skills): array
    {
        return collect($skills)->map(fn (array $gap): array => [
            'skill_id' => (int) $gap['skill']['id'],
            'current_level' => $gap['current_level'],
            'target_level' => (int) $gap['target_level'],
            'gap' => $gap['gap'],
            'is_assessed' => $gap['is_assessed'],
        ])->all();
    }

    /** @param list<array{skill_id: int, current_level: ?int, target_level: int, gap: ?int, is_assessed: bool}> $gaps
     * @return list<array<string, mixed>>
     */
    private function priorities(array $gaps): array
    {
        return collect($gaps)->map(function (array $gap): array {
            $resourceIds = LearningResource::query()
                ->where('skill_id', $gap['skill_id'])
                ->where('is_active', true)
                ->whereNotNull('verified_at')
                ->pluck('id')
                ->map(fn ($id): int => (int) $id)
                ->take(1)
                ->all();

            return [
                'skill_id' => $gap['skill_id'],
                'reason' => 'Latihan pada kompetensi ini memperjelas langkah belajar berikutnya.',
                'tasks' => [[
                    'title' => 'Latihan terarah',
                    'description' => 'Kerjakan latihan kecil menggunakan materi yang tersedia.',
                    'estimated_hours' => 2,
                    'resource_ids' => $resourceIds,
                    'completion_criteria' => 'Simpan catatan praktik dan ringkasan hasilnya.',
                ]],
            ];
        })->all();
    }

    /** @param array<string, mixed> $structuredOutput */
    private function fakeOpenAi(array $structuredOutput): void
    {
        $this->configureOpenAi();
        Http::preventStrayRequests();
        Http::fake([
            'https://api.openai.com/v1/responses' => Http::response([
                'id' => 'resp_test',
                'model' => 'gpt-6-luna',
                'output' => [[
                    'type' => 'message',
                    'content' => [[
                        'type' => 'output_text',
                        'text' => json_encode($structuredOutput, JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR),
                    ]],
                ]],
            ]),
        ]);
    }

    private function configureOpenAi(): void
    {
        config([
            'services.openai.enabled' => true,
            'services.openai.api_key' => 'test-openai-key',
            'services.openai.model' => 'gpt-6-luna',
            'services.openai.base_url' => 'https://api.openai.com/v1',
            'services.openai.timeout' => 20,
            'services.openai.connect_timeout' => 5,
            'services.openai.max_output_tokens' => 800,
        ]);
    }
}
