# System Architecture

## 1. High-level architecture

```text
Flutter Mobile App
       |
       | HTTPS / JSON REST API
       v
Laravel Backend
  |       |         |
  |       |         +--> AI Provider (server-side only)
  |       |
  |       +------------> Curated Learning Resource Catalog
  |
  +--------------------> Relational Database
```

Flutter must not connect directly to the database or AI provider.

## 2. Flutter responsibilities
- Present screens and navigation.
- Collect user input.
- Perform client-side convenience validation.
- Call Laravel API.
- Display server results and errors.
- Store session credentials securely.
- Never own authoritative business rules.

## 3. Laravel responsibilities
- Authentication and authorization.
- Server-side validation.
- Business rules and skill-gap calculation.
- Database transactions and persistence.
- AI orchestration, prompt, schema validation, and fallback.
- Resource catalog validation.
- Rate limiting, logging, and audit-relevant metadata.

## 4. Database responsibilities
Persist users, career catalog, skill catalog, assessments, results, roadmaps, resources, progress, portfolio items, and job applications as needed by the agreed MVP.

## 5. AI boundary
AI receives only necessary context from Laravel. It returns structured candidate recommendations. Laravel validates all IDs, types, lengths, limits, and references before storing or returning output.

## 6. Environment configuration
Use separate development and production configuration. Secrets remain in backend environment/secret storage. `.env.example` contains placeholders only. Flutter base URL is environment-specific and must not contain secrets.

## 7. Deployment assumptions
Deployment provider, database engine, file storage, AI provider, and production domain are not fixed in this document. Inspect current project choices; do not invent them. Record decisions when selected.
