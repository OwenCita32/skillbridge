<?php

namespace App\Http\Controllers;

use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\PersonalAccessToken;

class AuthController extends Controller
{
    public function register(RegisterRequest $request): JsonResponse
    {
        $data = $request->validated();
        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => $data['password'],
        ]);

        return $this->issueToken($user, $request, 'Akun berhasil dibuat.', 201);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $data = $request->validated();
        $user = User::where('email', $data['email'])->first();

        if ($user === null || ! Hash::check($data['password'], $user->password)) {
            return ApiResponse::error('INVALID_CREDENTIALS', 'Email atau kata sandi tidak cocok.', 401);
        }

        return $this->issueToken($user, $request, 'Berhasil masuk.');
    }

    public function logout(Request $request): JsonResponse
    {
        $token = $request->user()?->currentAccessToken();

        if ($token instanceof PersonalAccessToken) {
            $token->delete();
        }

        return ApiResponse::success(['logged_out' => true], 'Anda sudah keluar.');
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->user()->load('careerGoal.career');

        return ApiResponse::success(
            ['user' => (new UserResource($user))->resolve($request)],
            'Profil berhasil dimuat.',
        );
    }

    private function issueToken(User $user, Request $request, string $message, int $status = 200): JsonResponse
    {
        $expiresAt = now()->addMinutes(max(1, (int) config('sanctum.expiration', 43200)));
        $token = $user->createToken('skillbridge-mobile', ['*'], $expiresAt);
        $user->load('careerGoal.career');

        return ApiResponse::success([
            'user' => (new UserResource($user))->resolve($request),
            'token' => $token->plainTextToken,
            'token_type' => 'Bearer',
            'expires_at' => $expiresAt->toIso8601String(),
        ], $message, $status);
    }
}
