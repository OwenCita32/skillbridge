<?php

namespace Tests\Feature;

use App\Models\Career;
use App\Models\Roadmap;
use App\Models\User;
use Database\Seeders\SkillBridgeDemoSeeder;
use Illuminate\Foundation\Testing\LazilyRefreshDatabase;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class RoadmapControllerTest extends TestCase
{
    use LazilyRefreshDatabase;

    public function test_roadmap_generation_returns_catalog_resources_and_persists_tasks(): void
    {
        $this->seed(SkillBridgeDemoSeeder::class);
        $career = Career::where('slug', 'cybersecurity-analyst')->firstOrFail();
        $user = User::factory()->create();
        $token = $user->createToken('test')->plainTextToken;
        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/career-goals', ['career_id' => $career->id]);
        $answers = $career->skillRequirements()->get()
            ->map(fn ($requirement): array => ['skill_id' => $requirement->skill_id, 'level' => 0])
            ->all();
        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/assessments', ['answers' => $answers]);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/roadmaps/generate');
        $response->assertCreated()
            ->assertJsonPath('data.generation_mode', 'deterministic_fallback')
            ->assertJsonPath('data.items.0.status', 'not_started');

        $roadmap = Roadmap::where('user_id', $user->id)->firstOrFail();
        $this->assertModelExists($roadmap);
        $this->assertGreaterThan(0, $roadmap->items()->count());
        foreach ($response->json('data.items') as $item) {
            foreach ($item['resources'] as $resource) {
                $this->assertDatabaseHas('learning_resources', [
                    'id' => $resource['id'],
                    'is_active' => true,
                ]);
            }
        }
    }

    public function test_roadmap_generation_returns_409_without_an_assessment(): void
    {
        $this->seed(SkillBridgeDemoSeeder::class);
        $career = Career::where('slug', 'cybersecurity-analyst')->firstOrFail();
        $user = User::factory()->create();
        $token = $user->createToken('test')->plainTextToken;
        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/career-goals', ['career_id' => $career->id]);

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/roadmaps/generate')
            ->assertConflict()
            ->assertJsonPath('error.code', 'ASSESSMENT_REQUIRED');
    }

    public function test_progress_update_is_persisted_and_scoped_to_the_current_user(): void
    {
        $this->seed(SkillBridgeDemoSeeder::class);
        $career = Career::where('slug', 'cybersecurity-analyst')->firstOrFail();
        $owner = User::factory()->create();
        $ownerToken = $owner->createToken('test')->plainTextToken;
        $this->withHeader('Authorization', 'Bearer '.$ownerToken)
            ->postJson('/api/v1/career-goals', ['career_id' => $career->id]);
        $answers = $career->skillRequirements()->get()
            ->map(fn ($requirement): array => ['skill_id' => $requirement->skill_id, 'level' => 0])
            ->all();
        $this->withHeader('Authorization', 'Bearer '.$ownerToken)
            ->postJson('/api/v1/assessments', ['answers' => $answers]);
        $itemId = $this->withHeader('Authorization', 'Bearer '.$ownerToken)
            ->postJson('/api/v1/roadmaps/generate')
            ->assertCreated()
            ->json('data.items.0.id');

        $this->withHeader('Authorization', 'Bearer '.$ownerToken)
            ->patchJson('/api/v1/roadmap-items/'.$itemId.'/progress', ['status' => 'in_progress'])
            ->assertOk()
            ->assertJsonPath('data.status', 'in_progress');
        $this->assertDatabaseHas('progress_records', [
            'user_id' => $owner->id,
            'roadmap_item_id' => $itemId,
            'status' => 'in_progress',
        ]);

        $otherToken = User::factory()->create()->createToken('test')->plainTextToken;
        Auth::forgetGuards();
        $this->withHeader('Authorization', 'Bearer '.$otherToken)
            ->patchJson('/api/v1/roadmap-items/'.$itemId.'/progress', ['status' => 'completed'])
            ->assertNotFound();
    }
}
