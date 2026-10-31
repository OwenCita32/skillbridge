<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\LazilyRefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AuthControllerTest extends TestCase
{
    use LazilyRefreshDatabase;

    public function test_register_creates_a_user_and_returns_a_bearer_token(): void
    {
        $response = $this->postJson('/api/v1/register', [
            'name' => 'Ayu Analyst',
            'email' => 'ayu@example.test',
            'password' => 'secure-password',
            'password_confirmation' => 'secure-password',
        ]);

        $response->assertCreated()
            ->assertJsonPath('data.user.name', 'Ayu Analyst')
            ->assertJsonPath('data.token_type', 'Bearer');
        $user = User::where('email', 'ayu@example.test')->firstOrFail();

        $this->assertModelExists($user);
        $this->assertNotSame('secure-password', $user->password);
        $this->assertArrayNotHasKey('password', $response->json('data.user'));
        $this->assertDatabaseHas('personal_access_tokens', ['tokenable_id' => $user->id]);
    }

    public function test_login_returns_401_for_invalid_credentials(): void
    {
        User::factory()->create([
            'email' => 'ayu@example.test',
            'password' => Hash::make('correct-password'),
        ]);

        $this->postJson('/api/v1/login', [
            'email' => 'ayu@example.test',
            'password' => 'incorrect-password',
        ])->assertUnauthorized()
            ->assertJsonPath('error.code', 'INVALID_CREDENTIALS');
    }

    public function test_logout_revokes_the_current_token(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('test')->plainTextToken;

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/logout')
            ->assertOk();

        $this->assertDatabaseMissing('personal_access_tokens', ['tokenable_id' => $user->id]);
    }

    public function test_me_returns_401_without_a_valid_token(): void
    {
        $this->getJson('/api/v1/me')->assertUnauthorized()
            ->assertJsonPath('error.code', 'UNAUTHENTICATED');
    }
}
