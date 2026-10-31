<?php

namespace Tests\Feature;

use App\Exceptions\OpenAiResponseException;
use App\Services\OpenAiResponsesClient;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\Request as HttpRequest;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class OpenAiResponsesTest extends TestCase
{
    public function test_connection_probe_uses_responses_api_and_exact_model_without_exposing_key(): void
    {
        $apiKey = 'test-openai-secret';
        $this->configureFakeOpenAi($apiKey);
        Http::preventStrayRequests();
        Http::fake([
            'https://api.openai.com/v1/responses' => Http::response([
                'id' => 'resp_test_probe',
                'model' => 'gpt-6-luna',
                'output' => [[
                    'type' => 'message',
                    'content' => [['type' => 'output_text', 'text' => 'OK']],
                ]],
            ]),
        ]);

        $result = app(OpenAiResponsesClient::class)->connectionProbe();

        $this->assertSame('gpt-6-luna', config('services.openai.model'));
        $this->assertSame('gpt-6-luna', $result['model']);
        $this->assertSame('OK', $result['text']);
        $this->assertStringNotContainsString($apiKey, json_encode($result));
        Http::assertSent(fn (HttpRequest $request): bool => $request->method() === 'POST'
            && $request->url() === 'https://api.openai.com/v1/responses'
            && $request->data()['model'] === 'gpt-6-luna'
            && $request->data()['input'] === 'Reply with the single word OK.'
            && $request->data()['store'] === false
            && $request->hasHeader('Authorization', 'Bearer '.$apiKey));
    }

    public function test_structured_response_uses_strict_json_schema_format(): void
    {
        $this->configureFakeOpenAi();
        Http::preventStrayRequests();
        Http::fake([
            'https://api.openai.com/v1/responses' => Http::response([
                'id' => 'resp_test_structured',
                'output' => [[
                    'type' => 'message',
                    'content' => [[
                        'type' => 'output_text',
                        'text' => '{"answer":"A qualitative explanation."}',
                    ]],
                ]],
            ]),
        ]);

        $result = app(OpenAiResponsesClient::class)->createStructuredResponse(
            'test_schema',
            [
                'type' => 'object',
                'properties' => ['answer' => ['type' => 'string']],
                'required' => ['answer'],
                'additionalProperties' => false,
            ],
            'Return one concise answer.',
            ['context' => 'test'],
            120,
        );

        $this->assertSame('A qualitative explanation.', $result['answer']);
        Http::assertSent(fn (HttpRequest $request): bool => $request->data()['model'] === 'gpt-6-luna'
            && $request->data()['text']['format']['type'] === 'json_schema'
            && $request->data()['text']['format']['strict'] === true
            && $request->data()['store'] === false);
    }

    public function test_invalid_api_key_is_classified_without_echoing_the_key(): void
    {
        $apiKey = 'invalid-key-that-must-not-leak';
        $this->configureFakeOpenAi($apiKey);
        Http::preventStrayRequests();
        Http::fake(['https://api.openai.com/v1/responses' => Http::response(['error' => ['message' => 'secret echo']], 401)]);

        $exception = $this->captureOpenAiFailure();

        $this->assertSame('invalid_api_key', $exception->category);
        $this->assertSame(401, $exception->httpStatus);
        $this->assertStringNotContainsString($apiKey, $exception->getMessage());
        $this->assertStringNotContainsString('secret echo', $exception->getMessage());
    }

    public function test_rate_limit_is_classified(): void
    {
        $this->configureFakeOpenAi();
        Http::preventStrayRequests();
        Http::fake(['https://api.openai.com/v1/responses' => Http::response(['error' => ['message' => 'rate limit secret sentinel']], 429)]);

        $exception = $this->captureOpenAiFailure();

        $this->assertSame('rate_limit', $exception->category);
        $this->assertSame(429, $exception->httpStatus);
        $this->assertStringNotContainsString('secret sentinel', $exception->getMessage());
    }

    public function test_upstream_failure_is_classified(): void
    {
        $this->configureFakeOpenAi();
        Http::preventStrayRequests();
        Http::fake(['https://api.openai.com/v1/responses' => Http::response(['error' => ['message' => 'internal']], 500)]);

        $exception = $this->captureOpenAiFailure();

        $this->assertSame('api_failure', $exception->category);
        $this->assertSame(500, $exception->httpStatus);
        $this->assertStringNotContainsString('internal', $exception->getMessage());
    }

    public function test_transport_timeout_is_classified(): void
    {
        $this->configureFakeOpenAi();
        Http::preventStrayRequests();
        Http::fake(fn (): never => throw new ConnectionException('Connection timed out with secret sentinel.'));

        $exception = $this->captureOpenAiFailure();

        $this->assertSame('timeout', $exception->category);
        $this->assertStringNotContainsString('secret sentinel', $exception->getMessage());
    }

    public function test_rejects_a_model_other_than_the_requested_gpt_6_luna(): void
    {
        $this->configureFakeOpenAi();
        config(['services.openai.model' => 'gpt-6-astra']);
        Http::preventStrayRequests();

        $exception = $this->captureOpenAiFailure();

        $this->assertSame('unsupported_model', $exception->category);
        Http::assertNothingSent();
    }

    public function test_missing_key_fails_closed_without_making_a_request(): void
    {
        $this->configureFakeOpenAi();
        config(['services.openai.api_key' => null]);
        Http::preventStrayRequests();

        $exception = $this->captureOpenAiFailure();

        $this->assertSame('missing_api_key', $exception->category);
        Http::assertNothingSent();
    }

    private function configureFakeOpenAi(string $apiKey = 'unit-test-key'): void
    {
        config([
            'services.openai.enabled' => true,
            'services.openai.api_key' => $apiKey,
            'services.openai.base_url' => 'https://api.openai.com/v1',
            'services.openai.model' => 'gpt-6-luna',
            'services.openai.timeout' => 20,
            'services.openai.connect_timeout' => 5,
            'services.openai.max_output_tokens' => 800,
        ]);
    }

    private function captureOpenAiFailure(): OpenAiResponseException
    {
        try {
            app(OpenAiResponsesClient::class)->connectionProbe();
        } catch (OpenAiResponseException $exception) {
            return $exception;
        }

        $this->fail('Expected the OpenAI request to fail.');
    }
}
