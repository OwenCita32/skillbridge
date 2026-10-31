<?php

namespace App\Console\Commands;

use App\Exceptions\OpenAiResponseException;
use App\Services\OpenAiResponsesClient;
use Illuminate\Console\Attributes\Description;
use Illuminate\Console\Attributes\Signature;
use Illuminate\Console\Command;

#[Signature('openai:test')]
#[Description('Send a small, secret-safe probe to the configured OpenAI Responses API.')]
class TestOpenAiConnection extends Command
{
    public function handle(OpenAiResponsesClient $client): int
    {
        $keys = $client->apiKeys();

        if (empty($keys)) {
            $this->error('FAIL OpenAI Responses API category=missing_api_key');

            return self::FAILURE;
        }

        $allPassed = true;

        foreach ($keys as $index => $apiKey) {
            $keyNumber = $index + 1;
            $maskedKey = strlen($apiKey) > 12
                ? substr($apiKey, 0, 7).'...'.substr($apiKey, -4)
                : '***';

            try {
                $result = $client->connectionProbe($apiKey);

                if (strtoupper(trim($result['text'])) !== 'OK') {
                    $this->error("FAIL Key #{$keyNumber} ({$maskedKey}): Unexpected probe response.");
                    $allPassed = false;

                    continue;
                }

                $this->info(sprintf(
                    'PASS Key #%d (%s) model=%s response_id_received=%s',
                    $keyNumber,
                    $maskedKey,
                    config('services.openai.model'),
                    $result['response_id'] === '' ? 'no' : 'yes',
                ));
            } catch (OpenAiResponseException $exception) {
                $status = $exception->httpStatus === null ? '' : ' http_status='.$exception->httpStatus;
                $this->error("FAIL Key #{$keyNumber} ({$maskedKey}): category={$exception->category}{$status}");
                $allPassed = false;
            }
        }

        return $allPassed ? self::SUCCESS : self::FAILURE;
    }
}
