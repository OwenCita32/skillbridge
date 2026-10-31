# AI Behavior and Guardrails

## 1. AI role
AI personalizes explanations and learning plans. It is not the authority for identity, access control, proficiency scoring, verified credentials, or resource URLs.

## 2. Inputs
Laravel may provide:
- Selected career and approved competency requirements.
- Assessed skill IDs and levels.
- Available study time and learning preferences when supplied.
- Approved learning resource records (ID, title, provider, description, verified URL).

Send the minimum necessary data. Never send passwords, tokens, database credentials, or unrelated personal information.

## 3. Deterministic skill gap
Calculate in backend code:
\\[
\\text{Skill Gap} = \\max(0,\\text{Target Level} - \\text{Current Level})
\\]
AI may explain the result and prioritize tasks but must not rewrite the calculated levels or gap.

## 4. Structured output
Require JSON constrained by a schema. Example conceptual shape:
```json
{
  "summary": "string",
  "priorities": [
    {
      "skill_id": "approved-id",
      "reason": "string",
      "tasks": [
        {
          "title": "string",
          "description": "string",
          "estimated_hours": 2,
          "resource_ids": ["approved-resource-id"],
          "completion_criteria": "string"
        }
      ]
    }
  ]
}
```
This is illustrative. Final schema must match backend models and API contract.

## 5. Validation
Laravel must validate:
- JSON shape and data types.
- Allowed skill/resource IDs.
- Text length and task count.
- Estimated hours and total workload bounds.
- Duplicate or contradictory tasks.
- User ownership and career association.

Reject unknown resource IDs. Never trust model-generated URLs.

## 6. Reliability
Use timeout, bounded retry, rate limit, and cost controls. Handle provider errors, malformed output, empty responses, and rate limits. Provide a deterministic fallback or a clear retryable error.

## 7. Prompt injection
Treat user-entered text and resource descriptions as untrusted data. They must not override system rules. Do not reveal internal prompts or hidden reasoning.

## 8. User-facing transparency
Explain that recommendations are AI-assisted and may need review. Do not promise employment, guaranteed competency, or guaranteed outcomes. Do not label evidence verified without actual verification.

## 9. Implemented MVP integration
Laravel calls the OpenAI Responses API at `/v1/responses` using the configured `gpt-6-luna` model. The API key, timeouts, and output token limit are environment configuration read only by Laravel; Flutter receives neither the key nor direct OpenAI access. Requests use strict JSON Schema output and `store: false`.

The `POST /skill-gaps/explanation` endpoint asks only for qualitative explanations and next actions. Backend-calculated levels, targets, gaps, and priority remain authoritative. If the provider is disabled, unavailable, rate-limited, times out, or returns invalid output, explanations use deterministic text.

The roadmap generator may ask the model for qualitative summaries and tasks. It supplies only active, verified database resource records and constrains output resource IDs to that set; Laravel validates IDs again before attaching resources. No model-generated URL is accepted or persisted. `generation_mode` and nullable `generation_model` disclose whether the roadmap used `openai_responses` or `deterministic_fallback`.

The application must present all skill ratings as self-assessment, never as certification or verified competency. AI-assisted recommendations can require user review and do not guarantee employment or outcomes.
