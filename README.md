# CYBER AI — Autonomous Personal Android Assistant

[![Build Cyber AI Release APK](https://github.com/OWNER/REPOSITORY/actions/workflows/build_apk.yml/badge.svg)](.github/workflows/build_apk.yml)
![Platform](https://img.shields.io/badge/Platform-Android%207.0%2B%20(API%2024%2B)-00F0FF?style=flat&logo=android)
![Flutter](https://img.shields.io/badge/Flutter-3.16%2B-02569B?style=flat&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.2%2B-0175C2?style=flat&logo=dart)
![License](https://img.shields.io/badge/License-Proprietary-8B5CF6)

**Cyber AI** is a personal AI assistant and autonomous workstation for Android, built with Flutter, Dart, and Kotlin. It combines natural-language and voice interaction, native Android application discovery and launching, intelligent YouTube Music & YouTube ReVanced routing, and a multi-phase 3D Website Generation Studio.

---

## 1. Feature Highlights

### ⚡ Voice & Conversational Intelligence
- **Five Explicit Assistant States**: `IDLE`, `LISTENING`, `PROCESSING`, `SPEAKING`, and `ERROR` reflected across the UI and custom holographic shader orb.
- **Offline Tutoring Fallback**: Answers in-depth inquiries (e.g. quantum physics, photosynthesis, neural network backpropagation) locally even when offline or without an API key.
- **Gemini Generative Engine**: Configurable API key, supporting `gemini-1.5-flash`, `gemini-1.5-pro`, and `gemini-2.0-flash-exp` with timeout resilience and automatic retry logic.
- **Voice Interruption**: User can say *"Stop speaking"*, tap the mute icon, or cancel voice input at any instant.

### 🎵 YouTube Music & ReVanced Routing
- **Configurable Music Targets**: Seamlessly prioritizes YouTube Music ReVanced (`app.revanced.android.apps.youtube.music`), official YouTube Music, YouTube ReVanced, or custom forks (e.g., RVX).
- **Honest Playback Reporting**: Distinguishes opening search results from starting playback; never makes unverified claims.
- **Fail-Safe Browser Fallback**: Automatically redirects to web playback if native media apps are unavailable.

### 🌐 AI 3D Website Generation Studio
- **Multi-Phase Pipeline**:
  - **Phase A**: Requirements Analysis & Intent Classification
  - **Phase B**: Design System & Layout Selection (10 layouts: SaaS, E-Commerce, Portfolio, Restaurant, Dashboard, Agency, Education, Entertainment, Product Launch)
  - **Phase C**: Original Copy & Semantic Structure
  - **Phase D**: CSS3 3D Perspective Transforms (`rotateX`, `rotateY`, `translateZ`), Glassmorphic Cards & JavaScript
  - **Phase E**: Sandboxed Security Validation (blocks `<applet>`, `<object>`, `file://`, `intent:`, and unauthorized platform calls)
  - **Phase F**: Sandboxed Viewport Preview (Mobile 375px, Tablet 768px, Desktop Full)
  - **Phase G**: Multi-Turn Iteration (*"Make it minimal"*, *"Add 3D hero"*, *"Change palette"*)
  - **Phase H**: Direct ZIP Export containing `index.html`, `styles.css`, `script.js`, and `README.md`.

### 📱 Android Native Phone Control
- **Application Discovery**: Safely queries launcher applications without requesting high-risk system privileges.
- **Single-Tap App Launch**: Launches installed packages via Android `Intent.ACTION_MAIN`.
- **System Settings Integration**: One-tap navigation to Android settings, Wi-Fi, audio, and app permission panels.

---

## 2. Architecture & Project Layout

```
CYBER AI/
├── .github/
│   └── workflows/
│       └── build_apk.yml             # GitHub Actions CI pipeline for APK compilation
├── android/
│   ├── app/
│   │   ├── build.gradle              # Android app Gradle configuration
│   │   └── src/main/
│   │       ├── AndroidManifest.xml   # Android permissions and <queries> declaration
│   │       ├── kotlin/com/cyberai/assistant/
│   │       │   └── MainActivity.kt   # Kotlin MethodChannel platform integration
│   │       └── res/                  # Launch themes and styles
│   ├── build.gradle                  # Root build script
│   ├── settings.gradle               # Flutter plugin loader
│   └── gradlew / gradlew.bat         # Gradle wrapper executables
├── assets/
│   └── config.json                   # App asset configuration
├── lib/
│   ├── main.dart                     # Main entry point & system UI setup
│   ├── app.dart                      # CyberAiApp widget & dependency injection
│   ├── core/
│   │   ├── config/app_config.dart    # Constants, models, package IDs
│   │   ├── errors/failures.dart      # Failure hierarchy (Network, Auth, Security)
│   │   ├── services/
│   │   │   ├── ai_service.dart       # Abstract AI service interface
│   │   │   ├── gemini_ai_service.dart# Gemini API client & offline tutoring base
│   │   │   ├── platform_bridge.dart  # MethodChannel bridge with test mock fallbacks
│   │   │   ├── speech_service.dart   # Speech-to-text with 5-state lifecycle
│   │   │   ├── storage_service.dart  # Local SharedPreferences persistence
│   │   │   ├── tts_service.dart      # Flutter TTS engine
│   │   │   └── website_generator.dart# Website generation pipeline orchestrator
│   │   ├── theme/
│   │   │   ├── cyber_colors.dart     # Charcoal/midnight backgrounds & neon accents
│   │   │   └── cyber_theme.dart      # Material 3 dark cyber aesthetic
│   │   └── utils/
│   │       └── intent_parser.dart    # Rule-based intent matching & validation
│   ├── features/
│   │   ├── apps/screens/             # App Launcher screen & models
│   │   ├── assistant/                # Assistant hub, holographic orb, state pill, chat
│   │   ├── history/screens/          # Command & chat history
│   │   ├── music/                    # YouTube Music & ReVanced routing service & screen
│   │   ├── settings/screens/         # User preferences, API key, speech controls
│   │   ├── voice/screens/            # Fullscreen holographic voice console
│   │   └── websites/                 # Website Studio, 3D CSS generator, preview, ZIP export
│   ├── models/user_preferences.dart  # Typed preferences model
│   └── widgets/                      # CyberCard, CyberButton, CyberTextField
├── test/
│   ├── intent_parser_test.dart       # Unit tests for intent classification
│   ├── music_target_test.dart        # Unit tests for music app routing & fallback
│   ├── security_validator_test.dart  # Security tests for sandbox validation
│   ├── user_preferences_test.dart   # Serialization & copyWith tests
│   └── website_generator_test.dart   # Generation & 3D CSS inspection tests
├── pubspec.yaml                      # Project dependencies & Flutter metadata
└── analysis_options.yaml             # Dart analyzer rules
```

---

## 3. Getting Started & Local Setup

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.16.0 or newer
- [Dart SDK](https://dart.dev/get-dart) 3.2.0 or newer
- [Java Development Kit (JDK)](https://adoptium.net/) 17
- Android SDK Platform 34 (Android 14) and build-tools 34.0.0+

### Setup Commands
```bash
# 1. Fetch dependencies
flutter pub get

# 2. Verify formatting
dart format --output=none --set-exit-if-changed lib test

# 3. Run analyzer checks
flutter analyze

# 4. Execute unit & logic tests
flutter test

# 5. Build release APK
flutter build apk --release
```

The compiled release artifact will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 4. Automated APK Build via GitHub Actions

A reproducible GitHub Actions CI workflow is configured at [`.github/workflows/build_apk.yml`](.github/workflows/build_apk.yml).

### How to trigger a build:
1. Push your changes to the `main` or `master` branch, or
2. Go to the **Actions** tab in your GitHub repository, select **Build Cyber AI Release APK**, and click **Run workflow**.

### How to download the APK:
1. Once the workflow run finishes successfully, click on the completed run.
2. Scroll to the bottom to the **Artifacts** section.
3. Download the **`cyber-ai-release-apk`** artifact.
4. Extract the `.zip` file to obtain `app-release.apk`.

---

## 5. Installing the APK on Android

1. Transfer `app-release.apk` to your Android device via USB, Google Drive, or direct browser download.
2. In Android Settings, navigate to **Security** (or **Apps & notifications** > **Special app access**) and enable **Install unknown apps** for the app you use to open the APK (e.g. Chrome or Files).
3. Tap `app-release.apk` and confirm the installation prompt.
4. Launch **Cyber AI**.
5. Grant Microphone permission when prompted to enable voice commands.

---

## 6. Security & Privacy Model

- **No Hardcoded Secrets**: No API keys or credentials are baked into source code.
- **Client-Side Storage**: Gemini API keys entered by the user are stored strictly inside private device storage (`SharedPreferences`).
- **Sandboxed WebView Preview**: Generated HTML/JS is prohibited from invoking Android native bridges or accessing local device files.
- **Data Erasure**: The user can delete chat history or wipe all local records at any time from the Settings screen.
