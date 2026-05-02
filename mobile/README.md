# Nomadia Mobile

Flutter source for the Nomadia demo app lives in `lib/` with dependencies in `pubspec.yaml`.

This environment did not have `flutter` or `dart` installed, so platform folders such as `android/`, `ios/`, `web/`, `linux/`, `macos/`, and `windows/` were not generated here.

After installing Flutter locally, generate the missing runner files from this folder:

```bash
flutter create .
flutter pub get
flutter run
```

If you use the Android emulator, the API client already points to `http://10.0.2.2:8000`.
