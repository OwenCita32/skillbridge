<?php

namespace Tests\Feature;

use App\Models\Career;
use App\Models\User;
use Database\Seeders\SkillBridgeDemoSeeder;
use Illuminate\Foundation\Testing\LazilyRefreshDatabase;
use Tests\TestCase;

class CareerControllerTest extends TestCase
{
    use LazilyRefreshDatabase;

    public function test_career_catalog_returns_skill_requirements_and_scale_definitions(): void
    {
        $this->seed(SkillBridgeDemoSeeder::class);

        $this->getJson('/api/v1/careers')
            ->assertOk()
            ->assertJsonPath('data.0.slug', 'cybersecurity-analyst')
            ->assertJsonPath('data.0.is_demo', true)
            ->assertJsonPath('data.0.assessment_scale.0.level', 0)
            ->assertJsonPath('data.0.assessment_scale.0.label', 'Belum mengenal')
            ->assertJsonPath('data.0.assessment_scale.5.level', 5)
            ->assertJsonPath('data.0.assessment_scale.5.label', 'Mahir');
    }

    public function test_career_goal_is_saved_for_the_authenticated_user(): void
    {
        $this->seed(SkillBridgeDemoSeeder::class);
        $career = Career::where('slug', 'cybersecurity-analyst')->firstOrFail();
        $user = User::factory()->create();
        $token = $user->createToken('test')->plainTextToken;

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/career-goals', ['career_id' => $career->id])
            ->assertOk()
            ->assertJsonPath('data.career.id', $career->id);

        $this->assertDatabaseHas('user_career_goals', [
            'user_id' => $user->id,
            'career_id' => $career->id,
        ]);
    }

    public function test_career_goal_returns_401_without_a_token(): void
    {
        $this->seed(SkillBridgeDemoSeeder::class);
        $career = Career::where('slug', 'cybersecurity-analyst')->firstOrFail();

        $this->postJson('/api/v1/career-goals', ['career_id' => $career->id])
            ->assertUnauthorized();
    }
}
