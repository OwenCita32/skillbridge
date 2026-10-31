<?php

namespace App\Http\Controllers\Concerns;

use App\Models\User;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

trait ResetsUserPasswords
{
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
}

