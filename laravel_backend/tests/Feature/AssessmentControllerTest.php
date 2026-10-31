<?php

namespace Tests\Feature;

use App\Models\Assessment;
use App\Models\Career;
use App\Models\User;
use Database\Seeders\SkillBridgeDemoSeeder;
use Illuminate\Foundation\Testing\LazilyRefreshDatabase;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class AssessmentControllerTest extends TestCase
{
    use LazilyRefreshDatabase;

    public function test_assessment_stores_one_self_rating_for_each_career_skill(): void
    {
        $this->seed(SkillBridgeDemoSeeder::class);
        $career = Career::where('slug', 'cybersecurity-analyst')->firstOrFail();
        $user = User::factory()->create();
        $token = $user->createToken('test')->plainTextToken;
        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/career-goals', ['career_id' => $career->id]);
        $answers = $career->skillRequirements()->orderBy('skill_id')->get()
            ->map(fn ($requirement, int $index): array => [
                'skill_id' => $requirement->skill_id,
                'level' => $index === 0 ? 0 : 2,
            ])->all();

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/assessments', ['answers' => $answers])
            ->assertCreated()
            ->assertJsonPath('data.assessment_type', 'self_assessment')
            ->assertJsonPath('data.is_verified', false)
            ->assertJsonPath('data.answers.0.level', 0)
            ->assertJsonPath('data.answers.0.level_label', 'Belum mengenal');

        $this->assertDatabaseCount('assessments', 1);
        $this->assertDatabaseCount('user_skill_assessments', count($answers));
    }

    public function test_assessment_returns_422_when_a_level_exceeds_the_scale(): void
    {
        $this->seed(SkillBridgeDemoSeeder::class);
        $career = Career::where('slug', 'cybersecurity-analyst')->firstOrFail();
        $user = User::factory()->create();
        $token = $user->createToken('test')->plainTextToken;
        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/career-goals', ['career_id' => $career->id]);
        $answers = $career->skillRequirements()->orderBy('skill_id')->get()
            ->map(fn ($requirement, int $index): array => [
                'skill_id' => $requirement->skill_id,
                'level' => $index === 0 ? 6 : 2,
            ])->all();

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/assessments', ['answers' => $answers])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['answers.0.level']);

        $this->assertDatabaseCount('assessments', 0);
    }

    public function test_unassessed_skills_are_distinct_from_an_assessed_zero(): void
    {
        $this->seed(SkillBridgeDemoSeeder::class);
        $career = Career::where('slug', 'cybersecurity-analyst')->firstOrFail();
        $user = User::factory()->create();
        $token = $user->createToken('test')->plainTextToken;
        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/career-goals', ['career_id' => $career->id]);

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/skill-gaps')
            ->assertOk()
            ->assertJsonPath('data.skills.0.current_level', null)
            ->assertJsonPath('data.skills.0.gap', null)
            ->assertJsonPath('data.skills.0.is_assessed', false);

        $answers = $career->skillRequirements()->orderBy('skill_id')->get()
            ->map(fn ($requirement, int $index): array => [
                'skill_id' => $requirement->skill_id,
                'level' => $index === 0 ? 0 : 2,
            ])->all();
        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/assessments', ['answers' => $answers]);
        $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/skill-gaps')
            ->assertOk()
            ->assertJsonPath('data.skills.0.current_level', 0)
            ->assertJsonPath('data.skills.0.current_level_label', 'Belum mengenal')
            ->assertJsonPath('data.skills.0.is_assessed', true);
    }

    public function test_assessment_result_returns_404_to_another_user(): void
    {
        $this->seed(SkillBridgeDemoSeeder::class);
        $career = Career::where('slug', 'cybersecurity-analyst')->firstOrFail();
        $owner = User::factory()->create();
        $ownerToken = $owner->createToken('test')->plainTextToken;
        $this->withHeader('Authorization', 'Bearer '.$ownerToken)
            ->postJson('/api/v1/career-goals', ['career_id' => $career->id]);
        $answers = $career->skillRequirements()->get()
            ->map(fn ($requirement): array => ['skill_id' => $requirement->skill_id, 'level' => 1])
            ->all();
        $assessmentId = $this->withHeader('Authorization', 'Bearer '.$ownerToken)
            ->postJson('/api/v1/assessments', ['answers' => $answers])
            ->assertCreated()
            ->json('data.id');
        $otherToken = User::factory()->create()->createToken('test')->plainTextToken;
        Auth::forgetGuards();

        $this->withHeader('Authorization', 'Bearer '.$otherToken)
            ->getJson('/api/v1/assessments/'.$assessmentId)
            ->assertNotFound();

        $this->assertSame(1, Assessment::count());
    }
}
