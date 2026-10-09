# Please find the apk file in the release section.


# TuList

TuList is a clean, modern task management mobile app built with Flutter and Firebase. It helps users organize daily tasks, set priorities, and keep everything synchronized across devices in real time with offline support.

---

## What It Does

- **Account & Verification**: Sign up and log in securely with email and password, with built-in email verification.
- **Task Organization**: Create, edit, and delete tasks with titles, notes, due dates, due times, and priority levels (Low, Medium, High).
- **Smart Grouping**: Automatically organizes tasks into Today, Tomorrow, This Week, and Later.
- **Search & Filters**: Quickly search by task name or filter by status and priority.
- **Real-Time Sync & Offline Mode**: Syncs with Firebase Firestore instantly, while keeping tasks accessible even when offline.
- **Modern Design**: Earthy olive green and deep maroon visual theme with smooth micro-interactions.

---

## Tech Stack

- **Framework**: Flutter (Dart)
- **Backend**: Firebase Authentication, Cloud Firestore
- **State Management**: Provider
- **Local Storage**: SharedPreferences, Firestore Offline Cache
- **Configuration**: flutter_dotenv (.env)

---

## Project Structure

```
lib/
├── models/
│   └── task_model.dart                # Task data model with Firestore serialization
├── providers/
│   ├── auth_provider.dart             # Authentication state management and verification workflows
│   └── task_provider.dart             # Task filtering, sorting, and state logic
├── screens/
│   ├── email_verification_screen.dart # Interactive email verification and auto check
│   ├── home_screen.dart               # Main task list dashboard and search
│   ├── login_screen.dart              # User sign in interface and navigation
│   ├── onboarding_screen.dart         # Introductory walkthrough screens for new users
│   ├── signup_screen.dart             # User account creation and input validation
│   └── task_form_screen.dart          # Create and edit task modal screen
├── services/
│   ├── auth_service.dart              # Firebase authentication operations and error handling
│   ├── preferences_service.dart       # Local persistent storage using shared preferences
│   └── task_service.dart              # Firestore CRUD operations and offline cache
├── theme/
│   └── app_theme.dart                 # Color scheme, light theme, and typography
├── utils/
│   ├── date_helpers.dart              # Date formatting and task timeline helpers
│   ├── responsive.dart                # Screen breakpoint utilities and layout helpers
│   └── validators.dart                # Form input text validation helper rules
├── widgets/
│   ├── app_error_banner.dart          # Animated error and status alert banner
│   ├── auth_text_field.dart           # Custom text field with input styling
│   ├── delete_task_dialog.dart        # Confirmation dialog for deleting task items
│   ├── filter_bar.dart                # Quick filter chips for task categories
│   ├── filter_box.dart                # Advanced filtering and sorting modal sheet
│   ├── priority_chip.dart             # Color-coded priority badges for tasks
│   └── task_card.dart                 # Interactive task card with completion toggle
├── firebase_options.dart              # Platform-specific Firebase configuration and credentials
└── main.dart                          # Application entry point and root providers
```

---

## Quick Start

### 1. Clone the project
```bash
git clone https://github.com/CharanSatwik/TuList.git
cd TuList
```

### 2. Set up environment variables
Copy the example environment file and add your Firebase credentials:
```bash
cp .env.example .env
```

Fill in your Firebase keys inside `.env`:
```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project-id.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=your-sender-id

FIREBASE_ANDROID_API_KEY=your-android-api-key
FIREBASE_ANDROID_APP_ID=your-android-app-id

FIREBASE_IOS_API_KEY=your-ios-api-key
FIREBASE_IOS_APP_ID=your-ios-app-id
FIREBASE_IOS_BUNDLE_ID=com.example.taskManagementApp
```

### 3. Install packages
```bash
flutter pub get
```

### 4. Run the app
```bash
flutter run
```

---

## Firebase Setup

1. Create a project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Email/Password** under **Authentication > Sign-in method**.
3. Create a **Firestore Database** and add these security rules:
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
4. Copy your project keys into `.env`.

---

## Build for Release

To generate an Android release APK:
```bash
flutter build apk --release
```
The output file will be located at `build/app/outputs/flutter-apk/app-release.apk`.
