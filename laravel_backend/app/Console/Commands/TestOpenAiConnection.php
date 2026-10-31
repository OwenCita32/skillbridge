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
        try {
            $result = $client->connectionProbe();
        } catch (OpenAiResponseException $exception) {
            $status = $exception->httpStatus === null ? '' : ' http_status='.$exception->httpStatus;
            $this->error('FAIL OpenAI Responses API category='.$exception->category.$status);

            return self::FAILURE;
        }

        if (strtoupper(trim($result['text'])) !== 'OK') {
            $this->error('FAIL OpenAI Responses API returned an unexpected probe response.');

            return self::FAILURE;
        }

        $this->info(sprintf(
            'PASS OpenAI Responses API model=%s response_id_received=%s',
            config('services.openai.model'),
            $result['response_id'] === '' ? 'no' : 'yes',
        ));

        return self::SUCCESS;
    }
}
