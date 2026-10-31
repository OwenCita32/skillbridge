<?php

namespace App\Http\Controllers;

use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
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

    public function forgotPassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => 'required|email',
        ]);

        $user = User::where('email', strtolower(trim($validated['email'])))->first();

        if ($user === null) {
            return ApiResponse::error('USER_NOT_FOUND', 'Email tidak terdaftar di sistem SkillBridge.', 404);
        }

        // Generate 6-digit verification recovery code (No SMTP / No Vendor needed)
        $code = (string) random_int(100000, 999999);

        DB::table('password_reset_tokens')->updateOrInsert(
            ['email' => $user->email],
            [
                'token' => Hash::make($code),
                'created_at' => now(),
            ]
        );

        return ApiResponse::success([
            'email' => $user->email,
            'reset_code' => $code,
            'expires_in_minutes' => 15,
        ], 'Kode pemulihan akun berhasil dibuat.');
    }

    public function resetPassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => 'required|email',
            'reset_code' => 'required|string|size:6',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $email = strtolower(trim($validated['email']));
        $record = DB::table('password_reset_tokens')->where('email', $email)->first();

        if ($record === null) {
            return ApiResponse::error('INVALID_TOKEN', 'Permintaan reset tidak ditemukan. Silakan minta kode baru.', 400);
        }

        // Cek kedaluwarsa (15 menit)
        if (now()->diffInMinutes($record->created_at) > 15) {
            DB::table('password_reset_tokens')->where('email', $email)->delete();

            return ApiResponse::error('TOKEN_EXPIRED', 'Kode pemulihan telah kedaluwarsa. Silakan minta kode baru.', 400);
        }

        // Verifikasi kode 6 digit
        if (! Hash::check($validated['reset_code'], $record->token)) {
            return ApiResponse::error('INVALID_CODE', 'Kode pemulihan 6 digit tidak cocok.', 400);
        }

        $user = User::where('email', $email)->first();
        if ($user === null) {
            return ApiResponse::error('USER_NOT_FOUND', 'Akun tidak ditemukan.', 404);
        }

        $user->update([
            'password' => $validated['password'],
        ]);

        DB::table('password_reset_tokens')->where('email', $email)->delete();

        return ApiResponse::success([
            'email' => $email,
        ], 'Kata sandi berhasil diperbarui. Silakan masuk kembali.');
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
