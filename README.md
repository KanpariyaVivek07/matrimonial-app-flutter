# 💍 Matrimonial App (Flutter)

A complete matrimonial mobile application built with **Flutter**. It covers onboarding, authentication, match browsing, chat, premium plans and profile management — with a clean, modern UI.

## ✨ Features

| Module | What it does |
|---|---|
| **Onboarding** | Intro screens for first-time users |
| **Auth** | Login / signup flow |
| **Home** | Suggested matches feed |
| **Match** | Browse and filter profiles |
| **Chat** | Conversation UI with emoji picker and image sharing |
| **Profile** | Detailed profile with photo viewer, share and badges |
| **Premium** | Plan upgrade screens |
| **Payment** | Payment flow UI |
| **Settings** | App preferences |

## 🛠 Tech Stack

- **Flutter / Dart** (SDK ^3.8.1)
- `provider` for state management
- `image_picker`, `photo_view`, `share_plus` for media
- `google_fonts`, `shimmer`, `font_awesome_flutter`, `badges` for UI
- `shared_preferences` for local storage
- `emoji_picker_flutter` for chat input

## 🚀 Getting Started

```bash
flutter pub get
flutter run
```

To build a release APK:

```bash
flutter build apk --release
```

## 📁 Project Structure

```
lib/
├── main.dart
├── Routes/       # App navigation
├── Screens/      # Auth, Chat, Home, Match, Onboarding,
│                 # Payment, Premium, Profile, Settings, Success
├── Utils/        # Helpers, theme, constants
├── Widget/       # Reusable widgets
└── assets/image/ # Images used by the app
```

## 📌 Notes

- This project was built as a Semester 5 (MADF) Flutter project.
- The app currently uses local/mock data — no backend is connected.
- App package name in `pubspec.yaml` is `textformfield` (left over from the starter template); rename it if you plan to publish.
