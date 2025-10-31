# WanderAI Mobile App

AI-powered travel planning mobile application built with Flutter for iOS and Android.

## 🌟 Features

- 🤖 **AI Travel Assistant** - Chat with AI for personalized travel recommendations
- 🗺️ **Smart Itinerary Planning** - AI-generated travel itineraries
- 📍 **Destination Discovery** - Browse and explore travel destinations
- 💰 **Expense Tracking** - Track and manage trip expenses
- 🔐 **Secure Authentication** - Firebase Auth with Google Sign-In
- 📱 **Cross-Platform** - Native performance on iOS and Android
- 🎨 **Beautiful UI** - Modern, intuitive interface with custom animations
- 📊 **Budget Insights** - Visual expense charts and analytics
- 🌐 **Offline Support** - Local data caching with Hive & SQLite

## 🛠️ Tech Stack

### Core

- **Framework**: Flutter 3.9.2+
- **Language**: Dart
- **State Management**: Riverpod 3.0.0
- **Navigation**: GoRouter 14.6.2

### Backend & Services

- **Authentication**: Firebase Auth
- **AI**: Firebase AI (Gemini)
- **HTTP Client**: Dio 5.7.0
- **Backend API**: WanderAI FastAPI Backend

### Local Storage

- **Database**: SQLite (sqflite)
- **Key-Value Storage**: Shared Preferences
- **NoSQL Storage**: Hive
- **File Storage**: Path Provider

### UI & Design

- **Fonts**: Google Fonts, Custom (Poppins, Roboto)
- **Icons**: Cupertino Icons, Custom SVG icons
- **Images**: Cached Network Image
- **Charts**: FL Chart
- **Animations**: Lottie, Shimmer
- **Vector Graphics**: Flutter SVG

### Code Generation & Build

- **Build Runner**: Code generation for Riverpod & JSON
- **Riverpod Generator**: Auto-generate providers
- **JSON Serializable**: Auto-generate JSON serialization
- **Custom Lint**: Code quality with Riverpod Lint

## 📋 Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher
- Android Studio / VS Code with Flutter extensions
- Xcode (for iOS development on macOS)
- Firebase project with configuration files
- WanderAI Backend API running

## 🚀 Quick Start

### 1. Installation

```bash
# Navigate to mobile directory
cd mobile

# Get Flutter dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Firebase Setup

#### Android

1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/`

#### iOS

1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/`

#### Configure Firebase Options

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

### 3. Environment Configuration

The app connects to your backend API. Update the API base URL in `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://your-backend-url:8000';
  // For local development:
  // Android Emulator: 'http://10.0.2.2:8000'
  // iOS Simulator: 'http://localhost:8000'
  // Physical Device: 'http://YOUR_IP:8000'
}
```

### 4. Running the App

```bash
# Check connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in debug mode (default)
flutter run

# Run in release mode
flutter run --release

# Run on Chrome (web)
flutter run -d chrome

# Run on specific platform
flutter run -d android
flutter run -d ios
```

### 5. Build for Production

#### Android APK

```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

#### iOS

```bash
# Build for iOS
flutter build ios --release

# Build IPA (requires Xcode)
flutter build ipa --release
```

## 📁 Project Structure

```
mobile/
├── android/                    # Android native code
├── ios/                        # iOS native code
├── lib/
│   ├── main.dart              # App entry point
│   ├── firebase_options.dart  # Firebase configuration
│   ├── config/                # App configuration
│   │   ├── theme.dart
│   │   ├── routes.dart
│   │   └── api_config.dart
│   ├── models/                # Data models
│   │   ├── user.dart
│   │   ├── trip.dart
│   │   ├── destination.dart
│   │   └── expense.dart
│   ├── providers/             # Riverpod providers
│   │   ├── auth_provider.dart
│   │   ├── trip_provider.dart
│   │   └── chat_provider.dart
│   ├── screens/               # UI screens
│   │   ├── auth/
│   │   ├── home/
│   │   ├── trips/
│   │   ├── chat/
│   │   ├── expenses/
│   │   └── profile/
│   ├── services/              # Business logic & API calls
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── database_service.dart
│   │   └── storage_service.dart
│   ├── utils/                 # Utility functions
│   │   ├── constants.dart
│   │   ├── helpers.dart
│   │   └── validators.dart
│   └── widgets/               # Reusable widgets
│       ├── common/
│       ├── cards/
│       └── buttons/
├── assets/                     # Static assets
│   ├── images/
│   ├── icons/
│   ├── fonts/
│   └── lottie/
├── test/                       # Unit & widget tests
├── integration_test/           # Integration tests
├── pubspec.yaml               # Package dependencies
├── analysis_options.yaml      # Dart analyzer settings
└── README.md                  # This file
```

## 🎨 Design System

### Theme

The app uses a custom theme defined in `lib/config/theme.dart` with:

- Primary Color: Custom brand colors
- Typography: Poppins (headings) & Roboto (body)
- Dark/Light mode support

### Assets

- **Images**: PNG/JPG for photos and backgrounds
- **Icons**: SVG for scalable icons
- **Animations**: Lottie JSON files for smooth animations
- **Fonts**: Custom fonts (Poppins, Roboto)

## 🧪 Testing

### Unit Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/models/trip_test.dart

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
```

### Integration Tests

```bash
# Run integration tests
flutter test integration_test/

# Run on specific device
flutter test integration_test/ -d <device-id>
```

### Widget Tests

```bash
# Test specific widget
flutter test test/widgets/trip_card_test.dart
```

## 🔧 Development

### Code Generation

```bash
# Generate code (Riverpod, JSON serialization)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generate on file changes)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean generated files
flutter pub run build_runner clean
```

### Code Quality

```bash
# Analyze code
flutter analyze

# Format code
dart format lib/

# Custom lint (Riverpod)
dart run custom_lint
```

### Performance Profiling

```bash
# Run with performance overlay
flutter run --profile

# Trace performance
flutter run --trace-startup
```

## 🔌 API Integration

The app communicates with the WanderAI Backend API. Key endpoints:

- **Auth**: `/api/auth/*`
- **Trips**: `/api/trips/*`
- **Destinations**: `/api/destinations/*`
- **Expenses**: `/api/expenses/*`
- **Chat**: `/api/chat/*`

API client is configured in `lib/services/api_service.dart` using Dio with:

- Automatic token refresh
- Request/response logging (debug mode)
- Error handling
- Retry logic

## 🌐 Platform-Specific Notes

### Android

- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Requires Google Play Services for Firebase

### iOS

- Minimum iOS version: 12.0
- Requires Xcode 14.0+
- Requires CocoaPods for dependencies

### Web

- Responsive design for desktop browsers
- PWA support (installable)
- Firebase Auth web configuration required

## 🐛 Troubleshooting

### Common Issues

#### Pod Install Fails (iOS)

```bash
cd ios
pod deintegrate
pod install --repo-update
cd ..
```

#### Gradle Build Fails (Android)

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### Firebase Configuration Issues

```bash
# Reconfigure Firebase
flutterfire configure

# Check Firebase initialization
flutter run --verbose
```

#### Code Generation Not Working

```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Hot Reload Issues

```bash
# Full restart
# Press 'R' in terminal or
flutter run --hot
```

## 📦 Dependencies

### Main Dependencies

- `flutter_riverpod: ^3.0.0` - State management
- `go_router: ^14.6.2` - Navigation
- `dio: ^5.7.0` - HTTP client
- `firebase_core: ^3.8.1` - Firebase core
- `firebase_auth: ^5.3.3` - Authentication
- `sqflite: ^2.4.1` - Local database
- `hive: ^2.2.3` - NoSQL storage
- `cached_network_image: ^3.4.1` - Image caching
- `fl_chart: ^1.1.1` - Charts
- `lottie: ^3.1.3` - Animations

### Dev Dependencies

- `flutter_lints: ^5.0.0` - Linting rules
- `build_runner: ^2.4.13` - Code generation
- `riverpod_generator: ^3.0.0` - Provider generation
- `mockito: ^5.4.4` - Mocking for tests

## 🔐 Security

- Firebase Auth handles secure authentication
- API tokens stored securely using Flutter Secure Storage
- Sensitive data encrypted in local storage
- HTTPS only for API communication
- No hardcoded credentials (use environment config)

## 🚀 Deployment

### Android (Google Play Store)

1. Update version in `pubspec.yaml`
2. Generate signing key
3. Configure `android/key.properties`
4. Build app bundle: `flutter build appbundle --release`
5. Upload to Google Play Console

### iOS (App Store)

1. Update version in `pubspec.yaml`
2. Configure signing in Xcode
3. Build IPA: `flutter build ipa --release`
4. Upload via Xcode or Transporter

### Web

```bash
# Build for web
flutter build web --release

# Deploy to hosting (Firebase Hosting example)
firebase deploy --only hosting
```

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design Guidelines](https://m3.material.io/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests and linters
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Contribution Guidelines

- Follow Flutter/Dart style guide
- Write tests for new features
- Update documentation
- Use Riverpod for state management
- Follow project structure conventions

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## 👥 Authors

WanderAI Development Team

## 📧 Support

For questions, issues, or feature requests:

- Open an issue on GitHub
- Check the [Flutter documentation](https://docs.flutter.dev/)
- Join our community discussions

---

**Happy Coding! 🚀 Built with ❤️ using Flutter**
