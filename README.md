# Muscle Rich

A cross-platform mobile fitness app built with Flutter, designed to make working out simple, structured and personalised. Users sign up, complete a guided onboarding flow, and get access to a structured library of exercises across major muscle groups, each paired with a video demonstration and step-by-step instructions.

> **Status:** In active development as part of my final-year Computer Science project at the University of Essex.

---

## What it does

- **Authentication** — email/password and Google Sign-In flows powered by Firebase Auth
- **Onboarding** — collects user goals, experience level and preferences to personalise the experience
- **Exercise library** — workouts organised by body part (chest, back, legs, shoulders, arms) with difficulty levels (beginner, intermediate, advanced)
- **Exercise demos** — every exercise has a video demonstration streamed from Firebase Storage, plus written cues for form and execution
- **Workout flow** — guided "Start Workout" experience designed to keep the user moving without breaking focus
- **Profile & progress** — users can track their journey and update preferences over time

---

## Tech stack

| Layer | Tech |
|---|---|
| Framework | Flutter (Dart) |
| Backend | Firebase (Auth, Firestore, Storage) |
| Auth providers | Email/password, Google Sign-In, Sign in with Apple |
| Video playback | `video_player` + `chewie` |
| State | Stateful widgets with auth gating via `StreamBuilder` |
| Charts | `fl_chart` for progress visualisation |
| Platforms | iOS, Android |

---

## Project structure

```
lib/
├── main.dart                        # App entry, Firebase init
├── screens/
│   ├── auth/auth_gate.dart          # Routes user based on auth state
│   ├── login/login_screen.dart      # Email + social sign-in
│   ├── onboarding/                  # Goal & preference collection
│   ├── home/                        # Dashboard
│   ├── workout/                     # Body parts → exercise list → exercise detail
│   ├── plans/                       # Weekly plan view
│   ├── progress/                    # Charts and tracking
│   └── profile/                     # User settings
├── services/
│   └── auth_service.dart            # Firebase Auth wrapper
├── theme/                           # App-wide theming
└── widgets/                         # Reusable components
```

---

## Running it locally

This repo does not include the Firebase configuration files (they contain API keys and are intentionally gitignored). To run it yourself you'd need to:

1. Clone the repo
2. Set up your own Firebase project (Auth + Firestore + Storage)
3. Run `flutterfire configure` to generate `lib/firebase_options.dart`
4. Run `flutter pub get`
5. Run `flutter run`

---

## What I learned building this

- **Auth flow design is harder than it looks** — handling the gap between "user just signed in" and "user has a valid token for downstream services" took more thought than the sign-in UI itself
- **Firebase security rules are a feature, not an afterthought** — I caught a credential leak in my git history during this project and learned to treat `.gitignore` and Firestore/Storage rules as part of the build, not an extra
- **Cross-platform UI requires real discipline** — what looks great on iOS often needs adjustment on Android, especially around safe areas, navigation gestures and font rendering
- **Streaming video over Firebase Storage** — bandwidth, caching and playback states all matter. `chewie` handles a lot of this but you still need to think about loading and error states

---

## Roadmap

- AI-driven personalised workout recommendations
- 3D avatar customisation tied to user progress
- Progress dashboards backed by `fl_chart`
- Apple Health and Google Fit integration

---

## Author

**Aadit Sachdeva** — Final-year Computer Science student, University of Essex.
[Portfolio](https://aaditsachdeva.com) · [LinkedIn](https://www.linkedin.com/in/aadit-sachdeva-a2947a218/)
