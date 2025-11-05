# Ayna Catalog & Compare

Foundational scaffold for the Ayna Catalog & Compare Flutter application. This baseline delivers:

- Material 3 light/dark themes derived from dynamic primary color tokens.
- App-wide Inter/Cairo typography with tabular numbers via Google Fonts.
- `AppController` + `AppScope` with SharedPreferences persistence for theme, locale, and color.
- Manual localization delegate supporting English and Arabic with RTL directionality.
- Navigator 1.0 router wiring initial routes (Onboarding → Auth → Home).
- Soft-glass `GlassContainer` and floating `BottomDockNav` placeholder experience.

## Getting Started

```bash
flutter pub get
flutter run
```

Toggle theme/locale from the Settings placeholder or the quick access tile on the home shell.
