# API Contract

## 1. Purpose
This file is the shared contract between Flutter and Laravel. Endpoint list below is a proposal for the MVP; inspect existing routes and agree before implementation. Never let either side invent fields independently.

## 2. Conventions
- Base path proposal: `/api/v1`.
- Transport: HTTPS in deployed environments.
- Payload: JSON.
- Auth: bearer token if the chosen Laravel auth setup uses token authentication.
- Field naming: prefer `snake_case` for consistency with Laravel, unless the existing project already uses another convention.
- Timestamps: ISO 8601 with timezone.
- Collections: paginated where they may grow.
- Errors: stable machine-readable code plus safe user-facing message.

## 3. Candidate endpoints
| Method | Path | Purpose |
|---|---|---|
| POST | `/register` | Create account |
| POST | `/login` | Authenticate |
| POST | `/logout` | End session |
| GET | `/me` | Current user |
| GET | `/careers` | Career catalog |
| GET | `/careers/{career}` | Career details |
| POST | `/career-goals` | Set career goal |
| GET | `/skills` | Skill catalog |
| POST | `/assessments` | Submit assessment |
| GET | `/assessments/{assessment}` | Assessment result |
| GET | `/skill-gaps` | Current gap summary |
| POST | `/roadmaps/generate` | Request roadmap generation |
| GET | `/roadmaps/current` | Current roadmap |
| PATCH | `/roadmap-items/{item}/progress` | Update progress |
| GET | `/resources` | Curated resources |
| POST | `/portfolio-items` | Add evidence |
| GET | `/job-applications` | List applications |
| POST | `/job-applications` | Add application |

## 4. Response shape
Proposed success envelope:
```json
{
  "data": {},
  "meta": {},
  "message": "Success"
}
```
Use Laravel's standard validation response or one documented consistent error envelope. Do not mix response shapes unpredictably.

## 5. Error handling
Document behavior for 401 unauthenticated, 403 forbidden, 404 missing resource, 409 conflict, 422 validation/business rule, 429 rate limit, and 500 unexpected server error. Never expose stack traces or secrets.

## 6. AI roadmap request
The request should include only bounded preferences and relevant identifiers. User identity must come from authenticated context, not a client-supplied user ID. The response must contain validated roadmap records and approved resource IDs only.

## 7. Contract change procedure
Update this document first or in the same change as backend implementation. Update Flutter models/client and tests in the same task. Include sample request/response for every implemented endpoint.

## 8. Implemented MVP contract (`/api/v1`)

The following endpoints are implemented. All successful single-resource responses use `data`, `meta`, and `message`. Collection resources include Laravel pagination under `links` and `meta`. Bearer tokens are issued by Sanctum, expire after 43,200 minutes by default, and can be configured with `SANCTUM_EXPIRATION`.

| Method | Path | Auth | Result |
|---|---|---|---|
| POST | `/register` | No | Create account and issue token |
| POST | `/login` | No | Authenticate and issue token |
| POST | `/logout` | Bearer | Revoke current token |
| GET | `/me` | Bearer | Return current user and career goal |
| GET | `/careers` | No | Paginated career catalog |
| GET | `/careers/{career}` | No | Career, skills, targets, and scale |
| POST | `/career-goals` | Bearer | Set or replace the user's goal |
| GET | `/skills` | No | Paginated skill catalog |
| POST | `/assessments` | Bearer | Save a complete self-assessment |
| GET | `/assessments/{assessment}` | Bearer | Read an owned assessment |
| GET | `/skill-gaps` | Bearer | Current levels, targets, and gaps |
| POST | `/roadmaps/generate` | Bearer | Create AI-assisted roadmap from approved gaps/catalog, or deterministic fallback |
| POST | `/skill-gaps/explanation` | Bearer | Explain backend-calculated gaps without changing scores |
| GET | `/roadmaps/current` | Bearer | Read the current owned roadmap |
| PATCH | `/roadmap-items/{item}/progress` | Bearer | Append a progress update |
| GET | `/resources` | No | Paginated verified resource catalog; accepts `skill_id` and `category` filters |

### Authentication examples

`POST /register`

```json
{
  "name": "Ayu Analyst",
  "email": "ayu@example.com",
  "password": "strong-password",
  "password_confirmation": "strong-password"
}
```

`POST /login` uses `{ "email": "ayu@example.com", "password": "strong-password" }` and returns the same token fields as registration.

```json
{
  "data": {
    "user": { "id": 1, "name": "Ayu Analyst", "email": "ayu@example.com", "career_goal": null },
    "token": "<issued once>",
    "token_type": "Bearer",
    "expires_at": "2026-11-30T12:00:00+00:00"
  },
  "meta": {},
  "message": "Akun berhasil dibuat."
}
```

Send the token as `Authorization: Bearer <token>`. `GET /me` returns `data.user` with the user's `id`, `name`, `email`, and `career_goal` (`null` until selected). `POST /logout` returns `data.logged_out: true` and deletes the current token.

### Career, goal, and skill examples

`GET /careers` returns a paginated collection. `GET /careers/1` returns one item with the same fields:

```json
{
  "data": {
    "id": 1,
    "slug": "cybersecurity-analyst",
    "title": "Cybersecurity Analyst",
    "summary": "Contoh profil karier demo untuk mempelajari analisis keamanan.",
    "description": "Profil demonstrasi; target bukan standar universal.",
    "is_demo": true,
    "skills": [{ "id": 1, "slug": "networking-fundamentals", "name": "Networking fundamentals", "description": "...", "category": "networking", "target_level": 3 }],
    "assessment_scale": [{ "level": 0, "label": "Belum mengenal", "description": "Belum pernah mempelajari atau berhadapan dengan konsep ini." }],
    "assessment_notice": "Penilaian ini adalah estimasi diri, bukan sertifikasi atau bukti kompetensi terverifikasi."
  },
  "meta": {},
  "message": "Detail karier berhasil dimuat."
}
```

`assessment_scale` always contains levels 0 through 5 with labels and descriptions. `POST /career-goals` accepts `{ "career_id": 1 }` and returns `data.career` in the same shape. `GET /skills` returns the paginated skill catalog.

### Assessment and gap examples

`POST /assessments` requires one answer for every skill in the selected career. The example is abbreviated; send all career skill IDs exactly once.

```json
{ "answers": [{ "skill_id": 1, "level": 0 }, { "skill_id": 2, "level": 3 }] }
```

The created assessment response includes `assessment_type: "self_assessment"`, `is_verified: false`, a notice that it is not a certification, and `answers` with skill names and level labels. `GET /assessments/12` returns the same result only to its owner; another user receives 404.

`GET /skill-gaps` returns `data.career`, `data.assessment_id`, `data.assessment_notice`, and `data.skills`. Before the first assessment, a skill has `current_level: null`, `gap: null`, and `is_assessed: false`. An answered level 0 is a real rating and is returned as `current_level: 0`, label `Belum mengenal`.

```json
{
  "data": {
    "career": { "id": 1, "title": "Cybersecurity Analyst" },
    "assessment_id": 12,
    "assessment_notice": "Level kemampuan adalah penilaian diri dan tidak menyatakan kompetensi terverifikasi.",
    "skills": [{ "skill": { "id": 1, "name": "Networking fundamentals" }, "current_level": 0, "current_level_label": "Belum mengenal", "target_level": 3, "target_level_label": "Mampu mengerjakan dengan sedikit bantuan", "gap": 3, "is_assessed": true, "priority": "focus" }]
  },
  "meta": {},
  "message": "Analisis skill gap berhasil dimuat."
}
```

### Roadmap, progress, and resource examples

`POST /roadmaps/generate` accepts an empty JSON object after a career goal and assessment exist. Laravel calculates gaps first. The server may use OpenAI Responses API (`gpt-6-luna`) to personalize qualitative tasks; otherwise it creates deterministic tasks. In either mode, only active catalog resources with a `verified_at` date can be linked. The response includes `generation_mode` (`openai_responses` or `deterministic_fallback`) and nullable `generation_model`.

```json
{
  "data": {
    "id": 4,
    "career_id": 1,
    "career_title": "Cybersecurity Analyst",
    "generation_mode": "openai_responses",
    "generation_model": "gpt-6-luna",
    "summary": "Urutan tugas disusun dari gap terbesar dan resource terkurasi yang tersedia.",
    "items": [{ "id": 8, "position": 1, "skill": { "id": 1, "name": "Networking fundamentals" }, "title": "Pelajari Networking fundamentals", "estimated_hours": 6, "completion_criteria": "Selesaikan setidaknya satu materi yang tersedia dan tulis ringkasan atau hasil latihan untuk skill ini.", "status": "not_started", "resources": [{ "id": 1, "title": "Networking Basics", "description": "...", "category": "Networking", "type": "course", "url": "https://www.netacad.com/courses/networking-basics/how-routers-work", "source": "Cisco Networking Academy", "verified_at": "2026-10-31", "is_demo": true }] }]
  },
  "meta": {},
  "message": "Roadmap berhasil dibuat dari gap dan katalog resource terkurasi."
}
```

`POST /skill-gaps/explanation` accepts `{}` and requires bearer authentication plus a career goal and assessment. It returns the same backend-calculated skill levels and gaps as `GET /skill-gaps`, with qualitative `explanation` and `suggested_next_action` fields for each skill. `explanation_source` is `openai_responses` or `deterministic_fallback`; `model` is `gpt-6-luna` only for a successful model response, otherwise `null`. AI output cannot set or modify any score, gap, resource ID, or URL.

Example response excerpt:

```json
{
  "data": {
    "explanation_source": "openai_responses",
    "model": "gpt-6-luna",
    "fallback_reason": null,
    "skills": [{
      "skill": { "id": 1, "name": "Networking fundamentals" },
      "current_level": 0,
      "target_level": 3,
      "gap": 3,
      "explanation": "Pemahaman jaringan menjadi dasar untuk menganalisis lalu lintas sistem.",
      "suggested_next_action": "Pelajari materi terkurasi lalu catat hasil latihanmu."
    }]
  },
  "meta": {},
  "message": "Penjelasan skill gap berhasil dibuat."
}
```

`GET /roadmaps/current` returns the same roadmap shape. `PATCH /roadmap-items/8/progress` accepts `{ "status": "in_progress" }` and returns `{ "data": { "roadmap_item_id": 8, "status": "in_progress", "updated_at": "..." }, "meta": {}, "message": "Progress berhasil disimpan." }`. Allowed values are `not_started`, `in_progress`, `completed`, and `skipped`; the API records updates and lets a user correct a previous status.

`GET /resources?skill_id=1` returns a paginated list. Each item includes `title`, `description`, `category`, `type`, `url`, `source`, `verified_at`, and `is_demo`. The endpoint is read-only; clients cannot submit or override resource URLs.

### Error responses

- Laravel validation errors use `{ "message": "...", "errors": { "field": ["..."] } }` with status 422.
- Other API errors use `{ "error": { "code": "...", "message": "..." } }` with codes such as `UNAUTHENTICATED`, `NOT_FOUND`, `CAREER_GOAL_REQUIRED`, and `ASSESSMENT_REQUIRED`.
- Unexpected server errors return a generic 500 message; stack traces and secrets are not returned.
- Authentication endpoints are limited to 10 requests per minute per email/IP key. Roadmap generation is limited to 3 requests per minute per user.
- AI explanation is limited to 6 requests per minute per user. OpenAI credentials are read only by Laravel from environment configuration and are never sent to Flutter.

### Remaining endpoint samples

The examples below show the request body (or `—` for no body) and the successful `data` value. They use the demo IDs only to illustrate shape; clients must use IDs returned by the API.

| Endpoint | Request | Successful `data` sample |
|---|---|---|
| `POST /login` | `{ "email": "ayu@example.com", "password": "strong-password" }` | `{ "user": { "id": 1, "name": "Ayu Analyst", "email": "ayu@example.com", "career_goal": null }, "token": "<issued once>", "token_type": "Bearer", "expires_at": "2026-11-30T12:00:00+00:00" }` |
| `POST /logout` | `{}` | `{ "logged_out": true }` |
| `GET /me` | — | `{ "user": { "id": 1, "name": "Ayu Analyst", "email": "ayu@example.com", "career_goal": { "career_id": 1, "career_title": "Cybersecurity Analyst" } } }` |
| `POST /career-goals` | `{ "career_id": 1 }` | `{ "career": { "id": 1, "slug": "cybersecurity-analyst", "title": "Cybersecurity Analyst", "skills": [], "assessment_scale": [] } }` |
| `GET /skills` | — | `[{ "id": 1, "slug": "networking-fundamentals", "name": "Networking fundamentals", "description": "...", "category": "networking", "is_demo": true }]` |
| `GET /assessments/12` | — | `{ "id": 12, "career_id": 1, "assessment_type": "self_assessment", "is_verified": false, "answers": [{ "skill_id": 1, "skill_name": "Networking fundamentals", "level": 0, "level_label": "Belum mengenal" }] }` |
| `GET /roadmaps/current` | — | Same roadmap `data` shape as `POST /roadmaps/generate`; returns 404 when none exists. |
| `GET /resources?skill_id=1` | — | `[{ "id": 1, "title": "Networking Basics", "description": "...", "category": "Networking", "type": "course", "url": "https://www.netacad.com/courses/networking-basics/how-routers-work", "source": "Cisco Networking Academy", "verified_at": "2026-10-31", "is_demo": true }]` |

Portfolio and job application endpoints remain proposals and are not part of this MVP implementation.
