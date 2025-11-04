# Ethiopian Red Cross Society Mobile App

Flutter mobile application for the Ethiopian Red Cross Society platform.

## Features

- User authentication (Login/Register)
- Dashboard with statistics
- Events & Projects management
- Hub management
- Activity tracking
- Training programs
- Recognition & Awards
- Payments & Membership
- ID Card generation
- Mass Communication (Admin)
- Reports & Analytics
- Offline support with local caching

## Setup

1. Install Flutter SDK (3.0.0 or higher)
2. Run `flutter pub get`
3. Configure API URL in `lib/config/api_config.dart`
4. Run `flutter run`

## API Configuration

Update the API base URL in `lib/config/api_config.dart`:
```dart
const String apiBaseUrl = 'http://localhost:4000';
// or for production:
// const String apiBaseUrl = 'https://redcross-server.vercel.app';
```

## Build

- Android: `flutter build apk --release`
- iOS: `flutter build ios --release`

