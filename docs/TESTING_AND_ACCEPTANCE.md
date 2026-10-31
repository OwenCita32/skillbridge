# Testing and Acceptance Criteria

## 1. Core journey acceptance
- [ ] User can enter the app through the agreed auth/demo flow.
- [ ] User can select a career goal.
- [ ] User can complete and submit an assessment.
- [ ] Backend returns current level, target level, and calculated gap.
- [ ] Unassessed skills are clearly distinguished.
- [ ] User can view a roadmap with actionable tasks.
- [ ] Every roadmap resource references an approved catalog item.
- [ ] User can update task progress and see persisted state.
- [ ] Network/provider errors are handled without app crash.

## 2. Security acceptance
- [ ] User A cannot access User B's assessment, roadmap, evidence, or applications.
- [ ] Secrets are not present in Flutter source or git history.
- [ ] Server validates all client input.
- [ ] AI output is schema-validated.
- [ ] Unknown resource IDs are rejected.
- [ ] AI endpoint has reasonable rate/cost controls.

## 3. UI acceptance
- [ ] Consistent design tokens are used.
- [ ] Primary action is obvious.
- [ ] Loading, empty, error, and success states exist.
- [ ] No overflow on target screen sizes.
- [ ] Text is readable and contrast is sufficient.
- [ ] Long content and large text settings are handled.
- [ ] UI does not imply unearned verification or guaranteed employment.

## 4. Suggested test commands
Run commands appropriate to the installed versions and project scripts:
- Flutter: `dart format`, `flutter analyze`, `flutter test`.
- Laravel: `php artisan test`, plus configured formatter/linter.
- Database: run migrations and seeders in a disposable development/test database.
Do not run destructive commands against production.

## 5. Release readiness
- [ ] Main branch contains intended final code.
- [ ] Clean/understood git working tree.
- [ ] README setup instructions are accurate.
- [ ] AI use and third-party assets/services are declared as required.
- [ ] No secrets or private user data are committed.
- [ ] Demo flow has been manually verified.
- [ ] GitHub Release tag `submission-24h` points to the final submission commit.
