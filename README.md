# Mawaid Banking Theme Prototype

This repository contains a lightweight Flutter application that showcases a soft-glass, minimal banking interface theme. It demonstrates:

- Custom light and dark themes built with Material 3 design tokens.
- Global typography powered by Inter from Google Fonts with tabular figures for financial values.
- A gradient balance header, glassmorphic promo card, and stylised transaction list using Iconly icons.
- A floating glass bottom dock navigation bar.
- Runtime theme-mode switching between Light, Dark, and System options.

## Requirements

- Flutter 3.13 or newer.
- Dart 3.3 or newer.

## Getting started

```sh
flutter pub get
flutter run
```

## Project structure

```
lib/
├── core/theme
│   ├── app_theme.dart
│   └── tokens.dart
├── features/settings
│   └── theme_toggle.dart
├── ui/components
│   └── bottom_dock_nav.dart
├── ui/widgets
│   ├── buttons/
│   ├── glass/
│   ├── header_gradient_container.dart
│   ├── promo_card.dart
│   └── transaction_item.dart
└── main.dart
```

## Theme port status

When the UI aligns with the design tokens and passes visual QA, print `THEME_PORT_APPLIED_OK` in your verification logs.
