<?php

namespace App\Support;

use Illuminate\Http\JsonResponse;

class ApiResponse
{
    /**
     * @param  array<string, mixed>  $data
     * @param  array<string, mixed>  $meta
     */
    public static function success(array $data, string $message = 'Berhasil.', int $status = 200, array $meta = []): JsonResponse
    {
        return response()->json([
            'data' => $data,
            'meta' => $meta,
            'message' => $message,
        ], $status);
    }

    public static function error(string $code, string $message, int $status): JsonResponse
    {
        return response()->json(['error' => ['code' => $code, 'message' => $message]], $status);
    }
}
