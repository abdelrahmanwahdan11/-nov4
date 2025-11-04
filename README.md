# Greenly

A Flutter application concept showcasing sustainable meal discovery and electric car comparisons with rich theming and localization.

## Features

- Material 3 theming with dynamic seed color and dark mode support.
- Localization for English and Arabic with RTL handling.
- Splash and onboarding flows with guest access option.
- Authentication stubs for login, registration, and password recovery.
- Home and catalog listings with pagination, pull-to-refresh, and skeleton loaders.
- Product details with flip card nutritional info and cart management.
- Car comparison dashboard with localized filters, highlights, and upgraded 3D viewer controls.
- Settings for language, theme, and tutorial reset.

## Getting started

1. Ensure Flutter 3.13+ is installed.
2. Run `flutter pub get` to install dependencies.
3. Launch the app with `flutter run`.

### Binary asset policy

This repository disallows committing binary blobs. You can verify that no
binary files slipped in by running `python tool/check_no_binary.py`, which
fails the build if any tracked file cannot be decoded as UTF-8 text.

Web favicon and PWA icons use remote placeholder URLs so no binary art is
checked into the repository. The `.gitignore` also excludes the default
`flutter create` web icon outputs (`web/favicon.png` and `web/icons/`) to
prevent accidental binary commits when regenerating the web scaffold.

## Notes

- Data is loaded from local JSON mock files under `lib/data/mock`.
- Backend integrations are not included; repositories simulate latency.
- Tutorial coach marks and advanced animations are stubbed for demonstration.
