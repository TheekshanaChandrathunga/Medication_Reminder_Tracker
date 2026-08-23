# MediTrack Flutter

This is the Flutter conversion of the existing Expo prototype. The original Expo project remains unchanged in the parent folder.

## Run

1. Install Flutter and add its `bin` directory to PATH.
2. From this directory, generate the platform runners:

```powershell
flutter create . --platforms android,ios,web
```

3. Fetch packages and run the app:

```powershell
flutter pub get
flutter run
```

The UI, copy, colors, emoji icons, screen flow, and prototype interactions are implemented in `lib/main.dart`.
