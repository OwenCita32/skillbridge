# Development Standards

## 1. General
- Follow existing project conventions and installed framework versions.
- Prefer readable, explicit code over clever abstractions.
- Keep functions/classes focused.
- Avoid duplicated business rules across Flutter and Laravel.
- Do not add packages without a clear need.
- Remove debug code before release.

## 2. Naming
Use descriptive names. Follow language/framework conventions already present. API field names, enum values, and database columns must remain consistent.

## 3. Flutter
- Separate UI, state, and data access.
- Reuse theme tokens and shared widgets.
- Centralize API configuration and error mapping.
- Avoid network calls directly inside build methods.
- Handle async lifecycle and loading/error/empty states.
- Format and analyze before completing.

## 4. Laravel
- Thin controllers; validation via Form Requests where suitable.
- Authorization via policies/gates or explicit service checks.
- Business rules in focused services/actions.
- API Resources or consistent response formatting.
- Use transactions where multiple writes must succeed together.
- Avoid N+1 queries.

## 5. Configuration and secrets
- Never commit `.env`, tokens, API keys, signing keys, or private credentials.
- `.env.example` uses safe placeholders.
- Use separate development/production settings.
- Do not log secrets or sensitive user data.

## 6. Documentation
Update docs when changing user-visible behavior, API contracts, data model, status values, environment setup, or security assumptions.

## 7. Git hygiene
Review `git diff` and `git status`. Keep commits focused. Never force-push or discard user work without explicit authorization.
