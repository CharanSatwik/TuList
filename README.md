# Gig Task Management App

A Flutter task management application designed for gig workers to track shifts, client gigs, and prioritize tasks with offline persistence and cloud synchronization.

---

## Features & Visual Design

- **Primary Indigo & Lavender Aesthetic**: Indigo `#6C63FF` accents, curved lavender header, and Poppins typography.
- **Card Design**: Soft shadows, 18px rounded corners, circular checkboxes, and colored priority tags (`Low`, `Medium`, `High`).
- **Swipe to Delete**: Swipe left reveals a red circular delete button with an undo snackbar.
- **Task Categorization**: Auto-grouped into **Today**, **Tomorrow**, **This week**, and **Later**.
- **Multi-criteria Filtering**: Client-side filtering combining Status (`All`, `Incomplete`, `Completed`) and Priority (`All`, `Low`, `Medium`, `High`) while maintaining ascending due-date sort.
- **Task Management**: Create and edit tasks via a centered floating action button with title validation, multiline notes, date/time pickers, and segmented priority selection.
- **Offline Persistence**: Cloud Firestore offline cache enabled.
- **Responsive Layout**: Inset handling with `MediaQuery.padding` (no `SafeArea`).

---

## Project Structure

```
lib/
├── firebase_options.dart
├── main.dart
├── models/
│   └── task_model.dart
├── providers/
│   ├── auth_provider.dart
│   └── task_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── onboarding_screen.dart
│   ├── signup_screen.dart
│   └── task_form_screen.dart
├── services/
│   ├── auth_service.dart
│   └── task_service.dart
├── theme/
│   └── app_theme.dart
├── utils/
│   ├── date_helpers.dart
│   └── validators.dart
└── widgets/
    ├── auth_text_field.dart
    ├── filter_bar.dart
    ├── priority_chip.dart
    └── task_card.dart
```

---

## Setup Steps

### 1. Prerequisites
- Flutter SDK `^3.11.5` or higher
- Dart SDK installed
- Android SDK (or Xcode for iOS)

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run Analysis & Tests
```bash
flutter test
flutter analyze
```

---

## Firebase Configuration Instructions

### 1. Create a Firebase Project
1. Navigate to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** and follow the on-screen steps.

### 2. Enable Authentication
1. Under **Build**, select **Authentication**.
2. Click **Get Started**.
3. Under the **Sign-in method** tab, enable **Email/Password**.

### 3. Enable Cloud Firestore
1. Under **Build**, select **Firestore Database**.
2. Click **Create database** (start in Test mode or configure production rules).
3. Set up the security rules for the path `users/{uid}/tasks/{taskId}`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/tasks/{taskId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 4. Configure FlutterFire CLI
1. Install the Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```
2. Log in to Firebase:
   ```bash
   firebase login
   ```
3. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
4. Run configuration in the project root:
   ```bash
   flutterfire configure
   ```
   Follow the prompts to select your project and target platforms (Android, iOS, Web). This updates `lib/firebase_options.dart` and generates native configuration files (`google-services.json` / `GoogleService-Info.plist`).

---

## Running the App

```bash
# Debug run
flutter run
```

---

## Release APK Build Commands

### 1. Build a Universal Release APK
```bash
flutter build apk --release
```
*Output location:* `build/app/outputs/flutter-apk/app-release.apk`

### 2. Build Split-per-ABI APKs (Smaller file size for distribution)
```bash
flutter build apk --release --split-per-abi
```
*Output location:* `build/app/outputs/flutter-apk/app-<abi>-release.apk`

### 3. Build Android App Bundle (for Google Play submission)
```bash
flutter build appbundle --release
```
*Output location:* `build/app/outputs/bundle/release/app-release.aab`
