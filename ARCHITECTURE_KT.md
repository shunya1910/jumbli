# Jumbli - Knowledge Transfer (KT) & Architecture Document

## 1. Project Overview
**Jumbli** is a premium, completely offline, pass-and-play word scramble game for Android and iOS. 
- **Core Loop:** Player 1 enters a secret word. Player 2 has exactly 10 seconds to unscramble it.
- **Constraints:** No backend, no Firebase, no ads, no online multiplayer. 100% local execution.

## 2. Tech Stack
- **Framework:** Flutter (Dart)
- **UI System:** Material 3
- **Local Dev/CI:** Docker & Docker Compose (used to bypass local SDK installation limitations).
- **Key Packages:** `google_fonts` (Fredoka, Inter). Upcoming: `audioplayers`, `confetti`.

## 3. Architecture Pattern
The app strictly follows a **Feature-based Clean Architecture**. Code is separated by domains rather than by technical layers to ensure high maintainability.

### Folder Structure
```text
lib/
├── core/                   # App-wide shared resources
│   ├── theme/              # Design System (app_colors.dart, app_theme.dart, app_typography.dart)
│   └── utils/              # Shared utilities (validators.dart)
├── features/
│   └── game/               # The central game domain
│       ├── data/           # (Not heavily used as there is no DB/API)
│       ├── domain/         # Core business logic (game_engine.dart)
│       └── presentation/   # UI logic
│           ├── screens/    # Full pages (player_one_screen.dart, player_two_screen.dart)
│           └── widgets/    # Reusable UI components (scramble_animation.dart)
└── main.dart               # App entry point
```

## 4. Design System (`lib/core/theme/`)
- **Typography:** `Fredoka` for playful, bold headings. `Inter` for clean body text and buttons.
- **Color Palette:** 
  - Primary: Deep purple (`#6B4EE6`)
  - Secondary: Soft energetic red/pink (`#FFFF6B6B`)
  - Success: Vibrant green (`#4ADE80`)
  - Backgrounds: Cool greys/whites for Light Mode, Deep Slate for Dark Mode.
- **Components:** Uses highly rounded corners (16px+), subtle drop shadows, and gradients to give a "premium casual game" feel.

## 5. Core Game Logic (`lib/features/game/domain/game_engine.dart`)
The `GameEngine` handles all complex string manipulation decoupled from the UI:
- **`normalizeWord(word)`**: Strips whitespace and forces uppercase to prevent false negatives.
- **`scrambleWord(word)`**: Shuffles the letters using `dart:math`. Includes a `do-while` loop to guarantee the output is strictly different from the input (unless mathematically impossible, like "AAA").
- **`checkAnswer(original, guess)`**: Safely compares normalized words.

## 6. Game Flow State (So far)
1. **Player 1 Screen:** Handles input validation. Forces words between 3-12 letters, no spaces, no numbers. Shows a 3D animated `ScrambleAnimation` of the letters flipping when locked in.
2. **Player 2 Screen:** Receives the original and scrambled word. Starts a strict 10-second `Timer`. Handles `AppLifecycleState` to pause the timer if the user minimizes the app. Prevents double-submissions.

## 7. Developer Build Instructions (Docker Workflow)
Because of local permission constraints, all CLI commands are run via the official Flutter Docker container.

**To build the Android APK:**
```bash
docker run --rm -v $(pwd):/workspace -w /workspace ghcr.io/cirruslabs/flutter:stable /bin/bash -c "git config --global --add safe.directory /sdks/flutter && flutter build apk --debug && chown -R $(id -u):$(id -g) ."
```
**To run unit tests:**
```bash
docker run --rm -v $(pwd):/workspace -w /workspace ghcr.io/cirruslabs/flutter:stable /bin/bash -c "git config --global --add safe.directory /sdks/flutter && flutter test && chown -R $(id -u):$(id -g) ."
```
