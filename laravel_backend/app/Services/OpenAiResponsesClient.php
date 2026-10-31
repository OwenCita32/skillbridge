<?php

namespace App\Services;

use App\Exceptions\OpenAiResponseException;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use JsonException;

class OpenAiResponsesClient
{
    private static int $roundRobinCounter = 0;

    /** @return list<string> */
    public function apiKeys(): array
    {
        $keys = [];

        $key1 = config('services.openai.api_key');
        if (is_string($key1) && trim($key1) !== '') {
            $keys[] = trim($key1);
        }

        $key2 = config('services.openai.api_key_2');
        if (is_string($key2) && trim($key2) !== '') {
            $keys[] = trim($key2);
        }

        return array_values(array_unique($keys));
    }

    /** @return array{response_id: string, model: string, text: string} */
    public function connectionProbe(?string $apiKey = null): array
    {
        $payload = [
            'model' => $this->model(),
            'input' => 'Reply with the single word OK.',
            'max_output_tokens' => 16,
            'store' => false,
        ];

        $response = $apiKey !== null
            ? $this->sendWithKey($apiKey, $payload)
            : $this->send($payload);

        return [
            'response_id' => (string) ($response['id'] ?? ''),
            'model' => (string) ($response['model'] ?? $this->model()),
            'text' => $this->responseText($response),
        ];
    }

    /**
     * @param  array<string, mixed>  $schema
     * @param  array<string, mixed>  $context
     * @return array<string, mixed>
     */
    public function createStructuredResponse(
        string $schemaName,
        array $schema,
        string $instructions,
        array $context,
        int $maxOutputTokens,
    ): array {
        try {
            $encodedContext = json_encode($context, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR);
        } catch (JsonException $exception) {
            throw new OpenAiResponseException('invalid_response', previous: $exception);
        }

        $response = $this->send([
            'model' => $this->model(),
            'instructions' => $instructions,
            'input' => $encodedContext,
            'text' => [
                'format' => [
                    'type' => 'json_schema',
                    'name' => $schemaName,
                    'strict' => true,
                    'schema' => $schema,
                ],
            ],
            'max_output_tokens' => min($maxOutputTokens, (int) config('services.openai.max_output_tokens', 800)),
            'store' => false,
        ]);
        $text = $this->responseText($response);

        try {
            $decoded = json_decode($text, true, 512, JSON_THROW_ON_ERROR);
        } catch (JsonException $exception) {
            throw new OpenAiResponseException('invalid_response', previous: $exception);
        }

        if (! is_array($decoded)) {
            throw new OpenAiResponseException('invalid_response');
        }

        return $decoded;
    }

    private function model(): string
    {
        $model = (string) config('services.openai.model', 'gpt-6-luna');

        $allowed = [
            'gpt-6-luna',
            'gpt-4o',
            'gpt-4o-mini',
            'gpt-4-turbo',
            'gpt-4',
            'gpt-3.5-turbo',
            'o1-mini',
            'o1-preview',
        ];

        if (! in_array($model, $allowed, true)) {
            throw new OpenAiResponseException('unsupported_model');
        }

        return $model;
    }

    /**
     * @param  array<string, mixed>  $payload
     * @return array<string, mixed>
     */
    private function send(array $payload): array
    {
        if (! config('services.openai.enabled', true)) {
            throw new OpenAiResponseException('disabled');
        }

        $keys = $this->apiKeys();
        if ($keys === []) {
            throw new OpenAiResponseException('missing_api_key');
        }

        $keyCount = count($keys);
        $startIndex = self::$roundRobinCounter % $keyCount;
        self::$roundRobinCounter++;

        $orderedKeys = [];
        for ($i = 0; $i < $keyCount; $i++) {
            $orderedKeys[] = $keys[($startIndex + $i) % $keyCount];
        }

        $lastException = null;

        foreach ($orderedKeys as $idx => $apiKey) {
            try {
                return $this->sendWithKey($apiKey, $payload);
            } catch (OpenAiResponseException $exception) {
                $lastException = $exception;

                if (in_array($exception->category, ['invalid_api_key', 'rate_limit', 'timeout', 'transport_error'], true)) {
                    Log::warning('OpenAI request failed on current key. Attempting next key if available.', [
                        'key_attempt' => $idx + 1,
                        'total_keys' => $keyCount,
                        'category' => $exception->category,
                        'status' => $exception->httpStatus,
                    ]);
                    continue;
                }

                throw $exception;
            }
        }

        throw $lastException ?? new OpenAiResponseException('missing_api_key');
    }

    /**
     * @param  array<string, mixed>  $payload
     * @return array<string, mixed>
     */
    private function sendWithKey(string $apiKey, array $payload): array
    {
        try {
            $response = Http::acceptJson()
                ->asJson()
                ->withToken($apiKey)
                ->timeout((int) config('services.openai.timeout', 20))
                ->connectTimeout((int) config('services.openai.connect_timeout', 5))
                ->post(rtrim((string) config('services.openai.base_url'), '/').'/responses', $payload);
        } catch (ConnectionException $exception) {
            $category = str_contains(strtolower($exception->getMessage()), 'timed out')
                ? 'timeout'
                : 'transport_error';

            throw new OpenAiResponseException($category, previous: $exception);
        }

        if ($response->status() === 401 || $response->status() === 403) {
            throw new OpenAiResponseException('invalid_api_key', $response->status());
        }

        if ($response->status() === 429) {
            throw new OpenAiResponseException('rate_limit', 429);
        }

        if (! $response->successful()) {
            throw new OpenAiResponseException('api_failure', $response->status());
        }

        $data = $response->json();
        if (! is_array($data)) {
            throw new OpenAiResponseException('invalid_response', $response->status());
        }

        return $data;
    }

    /** @param array<string, mixed> $response */
    private function responseText(array $response): string
    {
        if (isset($response['output_text']) && is_string($response['output_text'])) {
            return $response['output_text'];
        }

        foreach ($response['output'] ?? [] as $outputItem) {
            if (! is_array($outputItem)) {
                continue;
            }

            foreach ($outputItem['content'] ?? [] as $contentItem) {
                if (! is_array($contentItem)) {
                    continue;
                }

                if (($contentItem['type'] ?? null) === 'refusal') {
                    throw new OpenAiResponseException('refusal');
                }

                if (($contentItem['type'] ?? null) === 'output_text' && is_string($contentItem['text'] ?? null)) {
                    return $contentItem['text'];
                }
            }
        }

        throw new OpenAiResponseException('invalid_response');
    }
}
