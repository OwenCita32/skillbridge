<?php

namespace App\Exceptions;

use RuntimeException;
use Throwable;

class OpenAiResponseException extends RuntimeException
{
    public function __construct(
        public readonly string $category,
        public readonly ?int $httpStatus = null,
        ?Throwable $previous = null,
    ) {
        parent::__construct(match ($category) {
            'disabled' => 'OpenAI integration is disabled.',
            'missing_api_key' => 'OpenAI API key is not configured.',
            'unsupported_model' => 'OpenAI model must be configured as gpt-6-luna.',
            'timeout' => 'OpenAI request timed out.',
            'transport_error' => 'OpenAI connection failed.',
            'invalid_api_key' => 'OpenAI rejected the configured API key.',
            'rate_limit' => 'OpenAI rate limit was reached.',
            'invalid_response' => 'OpenAI returned an invalid response.',
            'refusal' => 'OpenAI did not provide a usable response.',
            default => 'OpenAI request failed.',
        }, $httpStatus ?? 0, $previous);
    }
}
