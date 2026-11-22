# PulseBudget — Native Flutter App (Android & iOS)

100% offline USD budget management app built in native Flutter. Zero internet calls, persistent on-device storage via `shared_preferences` (survives closing the app and rebooting your phone), customizable Daily/Weekly/Monthly bar charts with saved defaults, left slide-out drawer, and second-precision transaction history.

## Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.2+)
- **For Android `.apk`**: Android Studio / Android SDK
- **For iPhone `.ipa`**: macOS with Xcode and an Apple Developer account (free Apple ID works for personal device install via Xcode)

## Build `.apk` (Android) & `.ipa` (iOS)

Unzip this folder, open a terminal inside `pulse_budget_flutter/`, and run:

```bash
# 1. Generate native android/ and ios/ platform folders (preserves lib/ and pubspec.yaml)
flutter create --project-name pulse_budget --org com.pulsebudget .

# 2. Fetch the single local-storage dependency (shared_preferences)
flutter pub get

# 3. Build Android APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# 4. Build iOS IPA (requires macOS + Xcode signing configured in ios/Runner.xcworkspace)
flutter build ipa --release
# Output: build/ios/ipa/pulse_budget.ipa
```

## Offline Privacy Note
This app makes zero network requests. When you run `flutter create`, Android's release manifest (`android/app/src/main/AndroidManifest.xml`) does not request `INTERNET` permission by default, keeping the installed app completely offline.
