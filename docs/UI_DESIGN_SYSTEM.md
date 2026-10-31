# SkillBridge — UI Design System

**Status:** Figma-reference-based visual specification  
**Platform:** Flutter mobile application  
**Design reference:** User-provided SkillBridge Figma screenshots (Splash, Onboarding, Personalization, AI Processing, and Learning screens).

This document is the visual implementation source of truth for the SkillBridge Flutter frontend. Follow it when creating or refining screens and reusable widgets. When an existing implementation conflicts with this document, prefer this document unless a newer approved Figma reference is supplied.

---

## 1. Visual Direction

SkillBridge uses a clean, modern, friendly productivity/learning interface. The visual identity is built around a vivid royal blue, near-white surfaces, dark navy typography, rounded white cards, soft shadows, and restrained pastel accents.

The interface should feel:
- Clear and approachable, not overly playful.
- Structured and information-focused.
- Spacious, with strong visual hierarchy.
- Consistent across onboarding, personalization, AI processing, and learning.
- Mobile-first, with primary actions easy to reach.

Do not introduce a different visual theme, dark dashboard aesthetic, heavy gradients, or excessive decorative elements.

## 2. Color Tokens

The values below are implementation starting points sampled/estimated from the supplied screenshots. Treat them as design tokens and centralize them in one Flutter theme/constants file. If exact Figma color values become available, replace these approximations consistently.

| Token | Hex | Usage |
|---|---|---|
| `primary` | `#3B63EC` | Main CTA, selected cards, progress bars, active indicators |
| `primaryDark` | `#2949B8` | Deep blue surfaces and emphasis |
| `primaryLight` | `#EAF0FF` | Selected backgrounds, pale blue panels |
| `primaryTint` | `#F2F5FF` | Subtle blue-tinted page backgrounds |
| `background` | `#F7F8FC` | Main app screen background |
| `surface` | `#FFFFFF` | Cards, sheets, inputs, navigation surfaces |
| `surfaceMuted` | `#F1F4F8` | Secondary containers and disabled areas |
| `textPrimary` | `#151B2B` | Main headings and important labels |
| `textSecondary` | `#7B8495` | Supporting text, descriptions, metadata |
| `textMuted` | `#A5ADBA` | Hints, inactive labels, timestamps |
| `border` | `#E7EBF2` | Card outlines, dividers, input borders |
| `success` | `#65C99A` | Completed states, success indicators |
| `successLight` | `#EAF8F0` | Success backgrounds |
| `warning` | `#F2C85B` | Highlights, badges, warning accents |
| `warningLight` | `#FFF8E5` | Informational/warning callouts |
| `purple` | `#8B78DF` | Secondary category and illustration accent |
| `coral` | `#F18A83` | Optional illustration accent |
| `disabled` | `#AFC1F2` | Disabled primary button |

### Color rules
- Blue is the dominant action and selection color.
- Use blue for one clear primary action per screen.
- Use green for completed/success states, not as a competing primary color.
- Use yellow sparingly for tips, highlights, and attention callouts.
- Use purple/coral mainly for category illustrations or secondary visual accents.
- Keep text contrast strong. Do not use pale accent colors for body text.
- Avoid applying gradients to every card. Reserve gradients for selected hero areas or the AI processing screen.

## 3. Typography

Use a geometric, modern sans-serif similar to the reference. Prefer **Plus Jakarta Sans** if available in the project; otherwise use **Inter**. Use one font family consistently.

| Style | Suggested size | Weight | Usage |
|---|---:|---:|---|
| Display | 30–34sp | Bold / ExtraBold | Splash title, major hero heading |
| H1 | 26–30sp | Bold | Main screen heading |
| H2 | 20–22sp | Bold | Section and card headings |
| H3 | 16–18sp | SemiBold / Bold | Card title and question |
| Body | 14–16sp | Regular | Paragraphs and descriptions |
| Body Small | 12–13sp | Regular | Supporting descriptions |
| Label | 11–12sp | SemiBold | Eyebrows, category, metadata |
| Button | 15–16sp | SemiBold | CTA text |
| Caption | 10–11sp | Medium | Progress labels and timestamps |

Typography rules:
- Use dark navy for headings and medium gray for descriptions.
- Keep line height comfortable (approximately 1.3–1.5 for body copy).
- Use sentence case for most labels and buttons.
- Use bold emphasis sparingly; do not make every line bold.
- Avoid long text blocks on mobile. Break content into short paragraphs or cards.

## 4. Spacing, Shape, and Elevation

Use a consistent 4-point spacing system.

| Token | Value |
|---|---:|
| `space2` | 2 |
| `space4` | 4 |
| `space8` | 8 |
| `space12` | 12 |
| `space16` | 16 |
| `space20` | 20 |
| `space24` | 24 |
| `space32` | 32 |
| `space40` | 40 |
| `space48` | 48 |

Recommended geometry:
- Screen horizontal padding: 20–24dp.
- Standard card padding: 16–20dp.
- Large hero card padding: 20–24dp.
- Small card radius: 16dp.
- Standard card radius: 20–24dp.
- Large hero/button radius: 18–22dp.
- Pill/badge radius: fully rounded.
- Primary button height: 54–60dp.
- Small icon button: 44–48dp minimum touch target.

Elevation:
- Use soft, low-opacity shadows under floating cards and primary buttons.
- Prefer a subtle border plus a soft shadow rather than a dark, strong shadow.
- Avoid multiple stacked shadows.
- Keep cards visually separated through whitespace first.

## 5. Core Components

Implement reusable components instead of styling each screen independently.

### Primary button
- Full-width on onboarding and form screens.
- Height approximately 56dp.
- Blue fill, white semi-bold label, rounded corners.
- Optional trailing arrow for forward navigation.
- Disabled state uses a muted blue fill and must remain legible.
- Include pressed/loading states.

### Secondary button
- White or pale surface with a subtle border.
- Dark navy label.
- Used for secondary actions only.

### Selection card
- White surface, rounded corners, subtle shadow/border.
- Selected state: blue outline, pale blue tint where appropriate, blue check/radio indicator.
- Unselected state: neutral border and empty radio/check control.
- Entire card should be tappable.
- Clearly distinguish selected, unselected, disabled, and focused states.

### Information / tip card
- Pale yellow or pale blue background.
- Small accent icon.
- Short explanatory text.
- Use for tips such as the explanation of how self-assessment is used to estimate a skill gap.

### Progress indicator
- Use blue for completed/current segments.
- Use pale gray for upcoming segments.
- Pair progress with a step count or concise label where useful.
- Do not rely on color alone to communicate progress.

### Category badge / chip
- Small pill with a pale tinted background.
- Compact text, medium/semi-bold.
- Use category-specific accent colors sparingly.

### Input field
- White surface with rounded corners.
- Neutral border by default; blue border on focus.
- Clear label, hint, validation, and error states.
- Do not use placeholder text as the only label.

### Learning content card
- White rounded card with clear title, type badge, duration, and short description.
- Video, practice, and reading content should have distinct type labels but share the same card system.
- Use a clear completion state for finished content.

## 6. Screen Specifications

### 6.1 Splash screen
- Full-screen primary blue background.
- Centered white rounded-square logo container.
- SkillBridge wordmark in large bold white text.
- Short tagline below the name.
- Subtle abstract curved-line decoration in a slightly lighter/darker blue with low opacity.
- Small loading indicator near the bottom.
- Keep the logo and text centered as one visual group.

### 6.2 Onboarding slides
- Near-white background with pale blue decorative shapes.
- Brand mark and SkillBridge name at the top.
- “Lewati” action at the top-right.
- Large illustration/card composition in the upper half.
- Small eyebrow label, bold headline, and concise supporting paragraph in the lower half.
- Step indicator near the bottom and circular blue next button.
- Final onboarding slide uses a full-width primary CTA such as “Mulai Perjalananmu”.

The three reference messages are:
1. Determine the career target.
2. Analyze skills and generate an intelligent roadmap.
3. Build a portfolio and start applying.

Keep the text concise and preserve the hierarchy: eyebrow → headline → description.

### 6.3 Personalization — choose profession
- Light neutral background.
- Top progress bar with step count (1/2).
- Large question heading and short helper text.
- Profession choices displayed as illustrated cards.
- Selected profession uses a clear blue border and check indicator.
- Use a two-column grid for compact profession cards where screen width allows; featured/selected card may span the full width if needed.
- Keep a fixed bottom primary button, with enough scroll padding so the last item is not hidden behind it.

### 6.4 Personalization — choose experience level
- Back control and segmented progress bar at the top.
- Large question heading and selected profession context.
- Three vertically stacked option cards: Pemula, Menengah, Mahir.
- Each card contains an icon, title, short explanation, and radio control.
- Selected option uses a strong blue fill with white text and a clear selected radio state.
- Unselected options use white surfaces and dark text.
- Add a pale yellow explanatory callout below the options.
- Fixed bottom primary button.

### 6.5 AI processing
- Full-screen deep/royal blue background.
- Subtle technical grid pattern with low opacity.
- Centered animated analysis visual (for example radar chart, circular progress, or abstract skill graph).
- Progress percentage or current stage visible.
- White heading and concise status text.
- Show selected profession and experience level as compact translucent chips.
- Show completed processing steps near the bottom with green check indicators.
- Animation must be smooth and must not block navigation indefinitely. Provide timeout/error handling and a retry path.

### 6.6 Learning — course overview
- Light neutral background.
- Top app bar with back navigation and course title.
- Blue/purple hero card containing category, course/test title, and short summary.
- Compact stat cards for number of questions, estimated duration, and lesson count/completion.
- Progress/score card with a horizontal progress bar and percentage.
- Primary CTA anchored near the bottom when appropriate.

### 6.7 Learning — quiz question
- Back control, course title, timer if required, and thin progress indicator.
- Display one question at a time in a clear hierarchy.
- Answer options as separate white rounded cards.
- Selected answer must have a visible blue selection state.
- Primary next button remains at the bottom.
- Disabled state until an answer is selected, if the question requires one.
- Ensure the question and all answers can scroll on smaller devices without being obscured by the CTA.

### 6.8 Learning — video task
- Top bar with back navigation, task title, and a Video badge.
- Large video player preview with a prominent play control.
- Timeline/duration information below the player.
- Supporting lesson outline in a white card.
- Primary completion button at the bottom; only mark complete after the intended completion condition is met.

### 6.9 Learning — practical task
- Top bar with back navigation, task title, and Praktik badge.
- Brief task description in a separate card.
- Checklist steps with large enough checkbox touch targets.
- Submission area for a project/evidence URL.
- Primary submit button at the bottom.
- Validate URL format and provide clear submission feedback.

### 6.10 Learning — reading task
- Top bar with back navigation, reading title, and Bacaan badge.
- Reading content in a white card with readable line length and spacing.
- Highlight important formulas or tips in a pale yellow callout.
- Primary “Selesai Membaca” action at the bottom.
- Avoid tiny text or dense full-width paragraphs.

## 7. Layout and Responsive Behavior

- Design mobile-first for common Android/iOS phone widths.
- Use `SafeArea` and respect system status/navigation bars.
- Use scrollable content for long forms and learning pages.
- Use a fixed bottom CTA only when it does not cover content; add bottom padding equal to CTA height plus safe-area inset.
- On narrow screens, switch grids to one column.
- On wider phones, use two-column profession/category cards where appropriate.
- Avoid hard-coded screen heights. Use constraints, flexible layouts, and scroll views.
- Support text scaling and prevent overflow on long Indonesian labels.
- Keep touch targets at least 44dp where practical.

## 8. Iconography and Illustration

- Use a consistent rounded icon style.
- Prefer simple, recognizable symbols for career categories, learning types, progress, and status.
- Use blue as the dominant icon color, with pastel green/yellow/purple backgrounds.
- Illustrations should be clean and lightweight, not photorealistic.
- Keep illustration cards visually consistent in size, padding, and corner radius.
- Avoid mixing unrelated icon packs or drastically different illustration styles.

## 9. Motion and Interaction

- Use short transitions (approximately 180–300ms) for selection, button feedback, and card state changes.
- Onboarding transitions should feel smooth and directional.
- AI processing may use a longer continuous animation, but always show meaningful progress/status.
- Provide pressed, loading, success, empty, disabled, and error states where relevant.
- Respect reduced-motion/accessibility settings where possible.
- Never use animation as the only indication that an operation succeeded.

## 10. Accessibility and Usability

- Maintain readable contrast for all text and controls.
- Do not encode state through color alone; include icons, labels, or shape changes.
- Support screen readers with meaningful semantic labels.
- Ensure controls have sufficient touch area.
- Handle keyboard visibility on forms.
- Prevent fixed CTAs from covering scrollable content.
- Use clear validation messages and actionable error states.

## 11. Flutter Implementation Rules for Codex

1. Define color, typography, spacing, radius, and elevation tokens centrally. Do not scatter raw hex values across widgets.
2. Build reusable widgets for primary/secondary buttons, selection cards, progress indicators, chips, input fields, and information cards.
3. Use `ThemeData`, `ColorScheme`, and shared `TextTheme` styles where practical.
4. Keep screen widgets focused on layout and state; move repeated visual patterns into reusable components.
5. Use responsive constraints rather than fixed pixel dimensions.
6. Use consistent `BorderRadius`, `EdgeInsets`, and spacing tokens.
7. Preserve the reference hierarchy and interaction states when implementing each page.
8. Do not add new colors, gradients, shadows, or decorative styles without a clear product reason.
9. Avoid placeholder-looking UI: every screen must include intentional empty/loading/error states.
10. Do not compromise accessibility to achieve pixel similarity.

Suggested Flutter organization (adapt to the existing project structure; do not duplicate folders unnecessarily):

```text
lib/
├── core/
│   └── theme/
│       ├── app_colors.dart
│       ├── app_spacing.dart
│       ├── app_radius.dart
│       └── app_theme.dart
└── shared/
    └── widgets/
        ├── primary_button.dart
        ├── selection_card.dart
        ├── progress_indicator.dart
        ├── info_callout.dart
        └── category_chip.dart
```

## 12. Design Acceptance Checklist

Before marking a screen complete, verify:

- [ ] Uses the shared SkillBridge color and typography tokens.
- [ ] Background, card surfaces, and text hierarchy match the reference.
- [ ] Primary CTA is visually dominant and consistently positioned.
- [ ] Cards use consistent radius, padding, border, and subtle elevation.
- [ ] Selected/unselected/disabled/loading/error states are implemented.
- [ ] Content remains readable and scrollable on small screens.
- [ ] Fixed bottom actions do not cover content.
- [ ] Long Indonesian text does not overflow.
- [ ] Icons and illustrations follow one visual style.
- [ ] The screen feels consistent with the supplied Figma flow.

---

**Important:** The screenshots provide visual guidance, not exact source design tokens. The hex values and dimensions in this document are practical approximations. Do not claim pixel-perfect Figma parity until exact Figma styles/assets and device dimensions are available.
