# SkillBridge

**Learn the Skills. Prove Them. Get Hired.**

SkillBridge is an AI-powered career readiness platform for university
students and fresh graduates. It helps users select a career goal,
assess their skills, understand skill gaps, follow a personalized
learning roadmap, access curated learning resources, and track learning
progress.

> **Project status:** MVP. Confirm every feature against the current
> source code before publishing a release.

## Table of Contents

-   [Overview](#overview)
-   [Core Features](#core-features)
-   [How It Works](#how-it-works)
-   [Technology Stack](#technology-stack)
-   [Architecture](#architecture)
-   [Repository Structure](#repository-structure)
-   [Setup](#setup)
-   [Running Locally](#running-locally)
-   [API](#api)
-   [AI Use and Third-Party
    Declaration](#ai-use-and-third-party-declaration)
-   [Security](#security)
-   [Testing](#testing)
-   [Limitations](#limitations)
-   [Contributing](#contributing)
-   [License](#license)

## Overview

SkillBridge helps learners connect their current abilities with the
skills expected in a target career. The demonstration career profile is
**Cybersecurity Analyst**.

### Target users

-   University students preparing for internships or their first job.
-   Fresh graduates planning their career development.
-   Early-career professionals structuring their learning.

## Core Features

  -----------------------------------------------------------------------
  Feature                             Description
  ----------------------------------- -----------------------------------
  Authentication                      Registration, login, token-based
                                      authentication, and logout.

  Career selection                    Choose a target career profile.

  Skill assessment                    Self-assess skills using a 0--5
                                      level scale.

  Skill-gap analysis                  Calculate the difference between
                                      current and target skill levels.

  AI skill-gap explanation            Explain skill gaps using the
                                      configured OpenAI model when
                                      available.

  Personalized roadmap                Generate a learning sequence based
                                      on skill gaps and available
                                      resources.

  Curated resources                   Present learning materials from the
                                      backend catalog.

  Progress tracking                   Record progress against learning
                                      activities.

  Deterministic fallback              Preserve basic functionality when
                                      the AI provider is unavailable.
  -----------------------------------------------------------------------

### Skill level scale

    Level Meaning
  ------- ------------------------------------------
        0 Belum mengenal
        1 Pemula
        2 Memahami dasar
        3 Mampu mengerjakan dengan sedikit bantuan
        4 Mampu mandiri
        5 Mahir

An unassessed skill is represented as `null`, not level `0`.

### Skill-gap calculation

The backend calculates the gap deterministically:

``` text
Skill Gap = max(0, Target Level - Current Level)
```

AI can explain the result and recommend learning activities, but must
not change assessment scores or calculated gaps.

## How It Works

1.  The user selects a career goal.
2.  The user completes a skill self-assessment.
3.  The backend calculates skill gaps.
4.  AI may explain the gaps in natural language.
5.  The system generates a learning roadmap using the available resource
    catalog.
6.  The user updates learning progress.

## Technology Stack

  -----------------------------------------------------------------------
  Layer                               Technology
  ----------------------------------- -----------------------------------
  Frontend                            Flutter / Dart

  Backend                             Laravel / PHP

  API authentication                  Laravel Sanctum

  AI provider                         OpenAI API

  AI interface                        OpenAI Responses API

  Intended AI model                   `gpt-6-luna`, configurable through
                                      `OPENAI_MODEL`

  Database                            Relational database; SQLite has
                                      been used for local development

  API format                          JSON over HTTP
  -----------------------------------------------------------------------

Exact dependency versions are defined in `flutter_frontend/pubspec.lock`
and `laravel_backend/composer.lock`.

## Architecture

``` text
Flutter Frontend
       |
       | JSON over HTTP / Bearer token
       v
Laravel Backend
   |           |
   v           v
Database    OpenAI Responses API
                |
          Configured AI model
```

Architecture rules:

-   Flutter calls Laravel; it must not call OpenAI directly.
-   OpenAI credentials stay on the Laravel backend.
-   Backend logic owns assessment validation and skill-gap calculation.
-   AI-generated resource IDs must be validated against the curated
    catalog.
-   Responses should distinguish AI-generated content from deterministic
    fallback content.

## Repository Structure

Expected project layout:

``` text
skillbridge/
├── docs/
│   ├── README.md
│   ├── CODEX_RULES.md
│   ├── PRODUCT_SPEC.md
│   ├── USER_FLOWS.md
│   ├── UI_DESIGN_SYSTEM.md
│   ├── SYSTEM_ARCHITECTURE.md
│   ├── DATABASE_DESIGN.md
│   ├── API_CONTRACT.md
│   ├── AI_BEHAVIOR.md
│   ├── DEVELOPMENT_STANDARDS.md
│   ├── MVP_SCOPE.md
│   └── TESTING_AND_ACCEPTANCE.md
├── flutter_frontend/
└── laravel_backend/
```

Update this tree if the actual repository differs. The root `README.md`
is the project entry point; detailed specifications are maintained in
`docs/`.

## Setup

### Prerequisites

-   Git
-   Flutter SDK and Dart SDK
-   PHP version compatible with the Laravel project
-   Composer
-   SQLite or another supported relational database
-   A web browser or supported Flutter target
-   OpenAI API account and API key for live AI tests

Check installed versions:

``` bash
flutter --version
dart --version
php --version
composer --version
```

### 1. Clone the repository

Replace the placeholder with the actual repository URL:

``` bash
git clone <YOUR_REPOSITORY_URL>
cd skillbridge
```

### 2. Install and configure Laravel

``` bash
cd laravel_backend
composer install
```

Create `.env`:

**Windows PowerShell**

``` powershell
Copy-Item .env.example .env
```

**macOS / Linux**

``` bash
cp .env.example .env
```

Generate the application key:

``` bash
php artisan key:generate
```

For SQLite, create the database file if needed:

**Windows PowerShell**

``` powershell
New-Item -ItemType File -Force database/database.sqlite
```

**macOS / Linux**

``` bash
touch database/database.sqlite
```

Configure the database in `.env`, according to the project's Laravel
configuration. Example:

``` env
DB_CONNECTION=sqlite
DB_DATABASE=database/database.sqlite
```

Run migrations:

``` bash
php artisan migrate
```

If the demonstration seeder exists and you want sample data:

``` bash
php artisan db:seed --class=SkillBridgeDemoSeeder
```

Use seeders only against a development database unless their behavior
has been reviewed for the target environment.

### 3. Configure OpenAI

Set the backend environment values in `laravel_backend/.env`:

``` env
OPENAI_API_KEY=your_openai_api_key
OPENAI_MODEL=gpt-6-luna
OPENAI_TIMEOUT=60
```

Use the exact variable names supported by the current backend
configuration. Never commit `.env`, expose the key in Flutter, or paste
it into public logs or issue reports.

After changing environment configuration:

``` bash
php artisan config:clear
```

### 4. Install Flutter dependencies

Open a second terminal:

``` bash
cd flutter_frontend
flutter pub get
```

Configure the API base URL for the target:

  -----------------------------------------------------------------------
  Target                              API base URL
  ----------------------------------- -----------------------------------
  Flutter Web in Chrome on the same   `http://127.0.0.1:8000/api/v1`
  computer                            

  Windows desktop on the same         `http://127.0.0.1:8000/api/v1`
  computer                            

  Android Emulator                    `http://10.0.2.2:8000/api/v1`
  -----------------------------------------------------------------------

If the project uses the `API_BASE_URL` Dart define, examples:

``` bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

``` bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

Do not use `10.0.2.2` for Flutter Web running in Chrome.

## Running Locally

Start Laravel from `laravel_backend`:

``` bash
php artisan serve
```

The default local address is:

``` text
http://127.0.0.1:8000
```

Keep the backend process running. In a separate terminal, start Flutter:

**Flutter Web**

``` bash
cd flutter_frontend
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

**Windows desktop**

``` bash
cd flutter_frontend
flutter run -d windows --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

**Android Emulator**

``` bash
cd flutter_frontend
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

These are local development commands. `php artisan serve` is not
intended to be the production web server.

## API

The versioned API base path is:

``` text
/api/v1
```

The implemented API includes routes for registration, login, logout,
career and skill catalogs, career-goal selection, skill assessment,
skill-gap retrieval and explanation, roadmap generation, resources, and
progress.

See [`docs/API_CONTRACT.md`](docs/API_CONTRACT.md) for request and
response schemas. Inspect the actual routes with:

``` bash
php artisan route:list --path=api
```

The `/api/v1` root may return `NOT_FOUND` if no index route is defined.
Test actual endpoints using their documented HTTP methods.

## AI Use and Third-Party Declaration

This section must be reviewed and updated to match the exact tools,
dependencies, assets, and services used in the submitted release.

### A. AI Use Declaration

**AI-assisted development**

AI tools may be used during development to assist with technical
explanations, code drafting or review, debugging, documentation, test
ideas, and UI/UX exploration. Generated outputs must be reviewed and
tested by the project developers; AI output is not automatically assumed
to be correct.

Declare only the tools actually used in the project:

  -----------------------------------------------------------------------
  Tool                    Potential use           Disclosure requirement
  ----------------------- ----------------------- -----------------------
  ChatGPT by OpenAI       Technical assistance,   Describe the actual
                          explanations, drafting, tasks for which it was
                          and review              used.

  OpenAI Codex, if used   Code generation, code   Describe the actual
                          modification, and test  tasks for which it was
                          assistance              used.
  -----------------------------------------------------------------------

Remove unused entries and add any other AI tools that were used.

**AI functionality in the application**

SkillBridge integrates the OpenAI API through the Laravel backend. The
model is configured using `OPENAI_MODEL`; the intended project
configuration is `gpt-6-luna`.

AI-supported application functions include:

-   Natural-language explanation of calculated skill gaps.
-   Personalized learning-roadmap generation based on the user's career
    goal, assessment results, and available learning resources.

The backend remains responsible for calculating assessment values and
skill gaps. AI output must not replace or modify those calculations. AI
recommendations are learning guidance; they do not guarantee employment,
certify competence, or replace professional evaluation.

When the AI provider is unavailable, the backend may use deterministic
fallback behavior. The application should identify whether a response
came from the AI provider or fallback logic.

**Suggested project-report disclosure:**

> SkillBridge uses the OpenAI API to support skill-gap explanations and
> personalized learning-roadmap recommendations. AI requests are made
> through the Laravel backend. Assessment values and skill-gap
> calculations are determined by application logic, while AI-generated
> content provides explanations and learning recommendations.
> AI-assisted development tools were also used where disclosed by the
> project team, and their outputs were reviewed and tested.

Edit this statement to reflect the actual implementation and development
process.

### B. Third-Party Software and Services

The following are documented technologies in the project stack. Verify
installed versions and license obligations from package manifests and
official license files before distribution.

  -----------------------------------------------------------------------
  Third party             Role                    License / terms
  ----------------------- ----------------------- -----------------------
  Flutter                 Frontend framework and  Refer to official
                          SDK                     Flutter license and
                                                  notices.

  Dart                    Frontend programming    Refer to official Dart
                          language and SDK        license and notices.

  Laravel                 Backend framework       MIT License; verify
                                                  installed version.

  PHP                     Backend runtime         PHP License; verify
                                                  installed version.

  Laravel Sanctum         API token               MIT License; verify
                          authentication          installed package
                                                  version.

  OpenAI API              AI explanations and     Subject to OpenAI API
                          roadmap generation      terms and applicable
                                                  usage policies; usage
                                                  may incur charges.

  SQLite, if configured   Local relational        Public domain.
                          database                

  MySQL, if configured    Relational database     Refer to the applicable
                          option                  MySQL license and
                                                  distribution terms.
  -----------------------------------------------------------------------

**Package-level dependencies:** Flutter and Laravel use additional
third-party packages. The dependency inventory is defined by:

-   `flutter_frontend/pubspec.yaml`
-   `flutter_frontend/pubspec.lock`
-   `laravel_backend/composer.json`
-   `laravel_backend/composer.lock`

Review direct and transitive dependency licenses before public or
commercial distribution. Also declare separately sourced icons, fonts,
illustrations, images, templates, datasets, and learning materials if
used.

### C. External Learning Resources

The demonstration resource catalog has included links from providers
such as Cisco Networking Academy, Ubuntu documentation, OWASP, Splunk,
Microsoft Learn, and Python documentation.

These materials are third-party resources and are not owned by
SkillBridge. Their content, trademarks, availability, and terms remain
controlled by their respective providers. Verify each URL and its
current terms before release.

### D. Attribution and Responsibility

-   Third-party trademarks belong to their respective owners.
-   External materials must retain their original attribution and
    licensing conditions.
-   Do not imply endorsement by OpenAI, Flutter, Laravel, or any
    learning-resource provider.
-   Maintain an up-to-date dependency and attribution inventory for
    every release.

## Security

-   Keep secrets in backend environment variables.
-   Do not commit `.env` files or API credentials.
-   Never place the OpenAI API key in Flutter source code or client-side
    configuration.
-   Protect user-specific assessment and progress endpoints with
    authentication and ownership checks.
-   Validate request data on the backend.
-   Validate AI-generated resource identifiers against the curated
    catalog.
-   Avoid logging passwords, bearer tokens, API keys, or sensitive user
    data.
-   Use HTTPS and production-grade secret management in deployment.
-   Review privacy and data-retention requirements before handling real
    user data.

## Testing

Run backend tests from `laravel_backend`:

``` bash
php artisan test
```

If Laravel Pint is installed:

``` bash
vendor/bin/pint --test
```

Run Flutter checks from `flutter_frontend`:

``` bash
flutter analyze
flutter test
```

Build a debug APK:

``` bash
flutter build apk --debug
```

### Recommended end-to-end test

1.  Register a test account.
2.  Log in and obtain an authenticated session.
3.  Select a career goal.
4.  Submit a skill assessment.
5.  Verify backend skill-gap calculations.
6.  Request a skill-gap explanation.
7.  Generate a personalized roadmap.
8.  Verify roadmap resource references against the catalog.
9.  Update learning progress.
10. Log out and log in again to verify persistence.
11. Test AI-provider failure and deterministic fallback.
12. Confirm that one user's assessment and progress cannot be accessed
    by another user.

Use mocked provider responses in automated tests. Run live-provider
tests separately, only with a valid API key and a suitable test
environment. Do not print API keys or authorization headers in test
output.

## Limitations

-   Assessments are self-reported unless a separate verification process
    is implemented.
-   AI recommendations may be incomplete or inaccurate and should be
    reviewed.
-   External resource URLs and availability can change.
-   AI API usage is subject to provider availability, rate limits,
    account configuration, and billing.
-   Deterministic fallback content is not the same as live AI-generated
    content and should be identified accurately.
-   Portfolio verification and job-application tracking should only be
    described as available if implemented in the current release.
-   SkillBridge does not guarantee interviews, job placement, or
    employment outcomes.

## Contributing

1.  Read the relevant documents in `docs/`.
2.  Keep Flutter and Laravel responsibilities separated.
3.  Keep AI-provider calls in the Laravel backend.
4.  Preserve deterministic skill-gap calculations.
5.  Validate AI output and resource references.
6.  Add or update automated tests.
7.  Update API and product documentation when behavior changes.
8.  Never commit secrets or personal data.

For significant changes, describe the problem, proposed solution, test
evidence, and impact on the API contract or database schema.

## License

**License: Not yet specified.**

This README does not grant an open-source license. Before publishing the
repository, the project owner should choose a license, add the
corresponding `LICENSE` file, and verify compatibility with third-party
dependencies and assets. If the project is proprietary or private, state
that explicitly instead of adding an open-source license without
authorization.

## Project Documentation

See [`docs/`](docs/) for product specifications, user flows, UI design,
system architecture, database design, API contract, AI behavior,
development standards, MVP scope, and testing criteria.
