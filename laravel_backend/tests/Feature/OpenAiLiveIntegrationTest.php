<?php

namespace Tests\Feature;

use App\Models\Career;
use App\Models\LearningResource;
use App\Models\User;
use App\Services\OpenAiResponsesClient;
use Database\Seeders\SkillBridgeDemoSeeder;
use Illuminate\Foundation\Testing\LazilyRefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class OpenAiLiveIntegrationTest extends TestCase
{
    use LazilyRefreshDatabase;

    public function test_live_responses_api_connection_uses_gpt_6_luna(): void
    {
        $this->enableLiveOpenAi();

        $probe = app(OpenAiResponsesClient::class)->connectionProbe();

        $this->assertSame('gpt-6-luna', config('services.openai.model'));
        $this->assertStringStartsWith('gpt-6-luna', $probe['model']);
        $this->assertSame('OK', strtoupper(trim($probe['text'])));
        $this->assertNotSame('', $probe['response_id']);
    }

    public function test_live_skill_gap_explanation_preserves_server_calculated_values(): void
    {
        $this->enableLiveOpenAi();
        $this->prepareAssessedUser();
        $before = $this->scoreSnapshot($this->getJson('/api/v1/skill-gaps')->assertOk()->json('data.skills'));

        $response = $this->postJson('/api/v1/skill-gaps/explanation');

        $response->assertOk()
            ->assertJsonPath('data.explanation_source', 'openai_responses')
            ->assertJsonPath('data.model', 'gpt-6-luna');
        $this->assertSame($before, $this->scoreSnapshot(
            $this->getJson('/api/v1/skill-gaps')->assertOk()->json('data.skills'),
        ));
    }

    public function test_live_personalized_roadmap_uses_only_database_resource_ids(): void
    {
        $this->enableLiveOpenAi();
        $this->prepareAssessedUser();
        $before = $this->scoreSnapshot($this->getJson('/api/v1/skill-gaps')->assertOk()->json('data.skills'));
        $catalogIds = LearningResource::query()
            ->where('is_active', true)
            ->whereNotNull('verified_at')
            ->pluck('id')
            ->map(fn ($id): int => (int) $id)
            ->all();

        $response = $this->postJson('/api/v1/roadmaps/generate');

        $response->assertCreated()
            ->assertJsonPath('data.generation_mode', 'openai_responses')
            ->assertJsonPath('data.generation_model', 'gpt-6-luna');
        foreach ($response->json('data.items') as $item) {
            foreach ($item['resources'] as $resource) {
                $this->assertContains((int) $resource['id'], $catalogIds);
            }
        }
        $this->assertSame($before, $this->scoreSnapshot(
            $this->getJson('/api/v1/skill-gaps')->assertOk()->json('data.skills'),
        ));
    }

    private function enableLiveOpenAi(): void
    {
        if (env('RUN_OPENAI_LIVE_TESTS') !== '1') {
            $this->markTestSkipped('Set RUN_OPENAI_LIVE_TESTS=1 to make billable live API requests.');
        }

        if (! is_string(config('services.openai.api_key')) || config('services.openai.api_key') === '') {
            $this->markTestSkipped('No OpenAI API key is configured in the Laravel environment.');
        }

        config([
            'services.openai.enabled' => true,
            'services.openai.model' => 'gpt-6-luna',
            'services.openai.timeout' => 25,
            'services.openai.connect_timeout' => 8,
            'services.openai.max_output_tokens' => 800,
        ]);
    }

    private function prepareAssessedUser(): void
    {
        $this->seed(SkillBridgeDemoSeeder::class);
        $career = Career::where('slug', 'cybersecurity-analyst')->firstOrFail();
        Sanctum::actingAs(User::factory()->create());
        $this->postJson('/api/v1/career-goals', ['career_id' => $career->id])->assertOk();

        $answers = $career->skillRequirements()->orderBy('skill_id')->get()
            ->map(fn ($requirement): array => [
                'skill_id' => (int) $requirement->skill_id,
                'level' => 0,
            ])->all();
        $this->postJson('/api/v1/assessments', ['answers' => $answers])->assertCreated();
    }

    /** @param list<array<string, mixed>> $skills
     * @return list<array{skill_id: int, current_level: ?int, target_level: int, gap: ?int, is_assessed: bool}>
     */
    private function scoreSnapshot(array $skills): array
    {
        return collect($skills)->map(fn (array $skillGap): array => [
            'skill_id' => (int) $skillGap['skill']['id'],
            'current_level' => $skillGap['current_level'],
            'target_level' => (int) $skillGap['target_level'],
            'gap' => $skillGap['gap'],
            'is_assessed' => $skillGap['is_assessed'],
        ])->all();
    }
}
