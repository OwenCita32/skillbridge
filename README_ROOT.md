# SkillBridge

**Learn the Skills. Prove Them. Get Hired.**

SkillBridge helps students and recent graduates choose a target career, estimate skill gaps with a structured self-assessment, and follow a learning roadmap tied to a curated resource catalog.

## Project layout

- `docs/` contains the product, API, architecture, UI, security, and acceptance specifications.
- `flutter_frontend/` contains the Flutter mobile client.
- `laravel_backend/` contains the Laravel REST API and SQLite development database.

Read [docs/README.md](./docs/README.md) and [docs/CODEX_RULES.md](./docs/CODEX_RULES.md) before changing product behavior or API contracts.

## Run the backend

From `laravel_backend/`:

```powershell
composer install
Copy-Item .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve --host=0.0.0.0
```

The default development database is SQLite. The repeatable seeder adds a demo Cybersecurity Analyst career, skills, and verified learning resources. Register a personal account in the app; the seeder does not create a demo user or credentials.

## Run Flutter

From `flutter_frontend/`:

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

`10.0.2.2` is the Android emulator's host-machine address. For Windows desktop or a local browser, use `http://127.0.0.1:8000/api/v1`. For an iOS simulator, use the API host address reachable from that simulator. Deployed environments must use HTTPS.

The app stores bearer tokens with `flutter_secure_storage`. The debug Android manifest permits local HTTP for development; release builds keep cleartext traffic disabled. Android builds require API level 24 or newer.

## Verify

```powershell
cd laravel_backend
php artisan test --compact
cd ..\flutter_frontend
flutter analyze
flutter test
```

Skill gap explanations and roadmaps use the server-side OpenAI Responses API with `gpt-6-luna` when `OPENAI_API_KEY` is configured. If OpenAI is unavailable, Laravel falls back to deterministic output. Keep the API key in `laravel_backend/.env`; it is never configured in Flutter. Set `OPENAI_ENABLED=false` to disable provider requests while retaining the fallback.

To run the optional Flutter-to-Laravel API flow test, start the backend with a disposable SQLite database and then run:

```powershell
flutter test --dart-define=RUN_API_INTEGRATION_TESTS=true --dart-define=API_TEST_BASE_URL=http://127.0.0.1:8765/api/v1 test/integration/api_flow_test.dart
```
