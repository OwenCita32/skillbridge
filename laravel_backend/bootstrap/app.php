<?php

use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        //
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*') || $request->expectsJson(),
        );

        $exceptions->render(function (Throwable $exception, Request $request) {
            if (! $request->is('api/*') || $exception instanceof ValidationException) {
                return null;
            }

            $status = match (true) {
                $exception instanceof AuthenticationException => 401,
                $exception instanceof AuthorizationException => 403,
                $exception instanceof ModelNotFoundException => 404,
                $exception instanceof HttpResponseException => $exception->getResponse()->getStatusCode(),
                $exception instanceof HttpExceptionInterface => $exception->getStatusCode(),
                default => 500,
            };
            $code = match ($status) {
                401 => 'UNAUTHENTICATED',
                403 => 'FORBIDDEN',
                404 => 'NOT_FOUND',
                409 => 'CONFLICT',
                429 => 'RATE_LIMITED',
                default => 'INTERNAL_SERVER_ERROR',
            };
            $message = match ($status) {
                401 => 'Autentikasi diperlukan.',
                403 => 'Anda tidak memiliki akses ke resource ini.',
                404 => 'Resource tidak ditemukan.',
                429 => 'Terlalu banyak permintaan. Coba lagi sebentar.',
                default => 'Terjadi kesalahan pada server.',
            };

            return response()->json(['error' => ['code' => $code, 'message' => $message]], $status);
        });
    })->create();
