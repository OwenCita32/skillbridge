# Database Design

## 1. Principles
This is a conceptual starting point, not a claim that migrations already exist. Inspect current migrations and database engine before changes.

- Use relational constraints and foreign keys.
- Normalize core transactional records.
- Use stable IDs.
- Keep status and level values canonical.
- Index common query patterns.
- Use transactions for multi-step updates.
- Do not store secrets in application tables.

## 2. Candidate entities
| Entity | Purpose |
|---|---|
| users | Account and profile |
| careers | Career catalog |
| skills | Skill catalog |
| career_skill_requirements | Target skill/level per career |
| user_career_goals | User's selected career |
| assessments | Assessment attempt metadata |
| assessment_questions | Assessment question bank, if applicable |
| assessment_answers | User answers |
| user_skill_assessments | Assessed skill level/result |
| roadmaps | User-specific learning roadmap |
| roadmap_items | Tasks/stages within a roadmap |
| learning_resources | Curated resource catalog |
| roadmap_item_resources | Resource-task mapping |
| progress_records | Task progress history/current state |
| portfolio_items | User evidence |
| job_applications | User application tracker |

Only create tables needed by the implemented scope. Avoid premature schema expansion.

## 3. Relationships (conceptual)
- Career ↔ Skill: many-to-many through career_skill_requirements.
- User → career goal: one or more over time; define active-goal rule.
- User → assessments: one-to-many.
- Assessment → answers/results: one-to-many.
- User → roadmaps: one-to-many.
- Roadmap → roadmap items: one-to-many.
- Roadmap item ↔ resources: many-to-many.
- User → portfolio items/job applications: one-to-many.

## 4. Skill level
The MVP uses the agreed self-assessment scale below for every skill:

| Level | Label | Meaning |
|---:|---|---|
| 0 | Belum mengenal | Belum pernah mempelajari atau berhadapan dengan konsep ini. |
| 1 | Pemula | Mulai mengenali istilah dan konsep, tetapi belum dapat menyelesaikan tugas dasar sendiri. |
| 2 | Memahami dasar | Memahami konsep dasar dan dapat menjelaskan istilah penting dengan contoh sederhana. |
| 3 | Mampu mengerjakan dengan sedikit bantuan | Dapat menyelesaikan tugas umum dengan arahan atau bantuan sesekali. |
| 4 | Mampu mengerjakan secara mandiri | Dapat merencanakan dan menyelesaikan tugas umum secara mandiri. |
| 5 | Mahir | Mampu menangani kasus kompleks, memilih pendekatan yang tepat, dan membimbing orang lain. |

`null` means the skill has not been assessed. Level 0 is an explicit self-rating and must never be used as the unassessed state. Career target levels are integers 1–5. The scale is an estimate only, not a certification or verified competency claim.

## 5. Skill gap
Backend calculation:
\\[
\\text{Skill Gap} = \\max(0,\\text{Target Level} - \\text{Current Level})
\\]
Persist enough context to understand which assessment and career requirement produced the result.

## 6. Suggested status values
Roadmap task: `not_started`, `in_progress`, `completed`, `skipped`.
Job application: `saved`, `applied`, `assessment`, `interview`, `offer`, `rejected`, `withdrawn`.
Confirm transition rules before enforcing them.

## 7. Integrity and privacy
- Every user-owned record must have an ownership path.
- Enforce access in Laravel policies/services, not only database IDs in URLs.
- Use deliberate cascade/restrict behavior.
- Portfolio visibility defaults to private.
- Uploaded file bytes should use controlled file/object storage; database stores metadata/reference.
- Define retention and deletion behavior.

## 8. Seed data
Seed a small demo Career profile and verified resources. Mark demo content clearly. Seeders should be repeatable where practical and must not include personal data or credentials.

## 9. Implemented MVP schema

The current migrations implement `personal_access_tokens`, `careers`, `skills`, `career_skill_requirements`, `user_career_goals`, `assessments`, `user_skill_assessments`, `learning_resources`, `roadmaps`, `roadmap_items`, `learning_resource_roadmap_item`, and `progress_records`.

- `user_career_goals.user_id` is unique, so each account has one current goal. Replacing it overwrites the previous goal (goal history is not retained) and deactivates the prior current roadmap.
- `user_skill_assessments.level` stores the explicit 0–5 self-rating. No result row means unassessed.
- `learning_resources` stores title, description, category, type, URL, source, verification date, active flag, and demo flag. Roadmaps attach catalog row IDs through the pivot; client- or model-generated URLs are never stored.
- `roadmaps.generation_mode` records `openai_responses` or `deterministic_fallback`; nullable `generation_model` records `gpt-6-luna` only for AI-assisted generation. This metadata does not store prompts, credentials, or generated URLs. `progress_records` is append-only; the newest record represents the task's current status, and status corrections are allowed.
- The repeatable demo seeder adds one clearly marked Cybersecurity Analyst profile, seven example skills/target levels, and six dated, curated learning resources. The profile targets and skill list are examples, not universal career standards.

Portfolio and application tables are not part of the current MVP migrations.
