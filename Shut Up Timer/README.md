# Main App Directory

This directory contains the core iOS application for Shut Up Timer, implementing the main timer functionality, user interface, and business logic.

## 🏗️ Architecture Overview

The app follows MVVM (Model-View-ViewModel) architecture with SwiftUI for the UI layer and Combine for reactive data flow. The main app coordinates between different modules and manages the overall application state.

## 📁 Directory Structure

```
Shut Up Timer/
├── Views/              # SwiftUI view components and screens
├── Models/             # Data models, Core Data entities, and business logic
├── ViewModels/         # MVVM view models for state management
├── API/               # Backend API clients and network layer
├── Modules/           # Feature-specific modules (Roast system, etc.)
├── Tokens/            # Design system tokens (colors, fonts, images)
├── Delegate/          # App delegates and system integration
├── Preview Content/   # SwiftUI preview resources
└── [Core App Files]   # Main app entry points and configuration
```

## 🔑 Key Files

### App Entry Points
- **`Shut_Up_TimerApp.swift`**: Main app entry point, initializes all managers and sets up subscriptions
- **`ContentView.swift`**: Root view container that hosts the main app interface
- **`AppRouter.swift`**: Navigation state management and view transitions
- **`AppRoute.swift`**: Route definitions for navigation

### Core Managers
- **`CredManager.swift`**: Authentication, user credentials, and backend integration
- **`SubscriptionManager.swift`**: In-app purchase handling and subscription state
- **`AnalyticsManager.swift`**: User behavior tracking and analytics
- **`SilentPushHandler.swift`**: Background notification processing

### Configuration & Utilities
- **`Config.swift`**: Environment-specific configuration (debug/release)
- **`Utilities.swift`**: Helper functions and utility methods
- **`PersistenceController.swift`**: Core Data stack management

## 🔄 Data Flow

### State Management
1. **App Initialization**: `Shut_Up_TimerApp.swift` creates and configures all managers
2. **Data Models**: `Models/` directory contains Core Data entities and business logic
3. **View Models**: `ViewModels/` handle UI state and business logic for specific views
4. **Views**: `Views/` directory contains SwiftUI components that observe view models

### Key Data Flows
- **Session Management**: Timer sessions flow through `SessionLoader` → `CredManager` → Supabase
- **Settings**: User settings flow through `SettingsLoader` → local storage
- **Authentication**: User auth flows through `CredManager` → Supabase
- **Subscriptions**: Purchase events flow through `SubscriptionManager` → `CredManager` → backend

## 🎯 Core Features

### Timer System
- **Session Management**: Tracks active timer sessions with Core Data
- **App Blocking**: Uses FamilyControls to prevent app switching
- **Live Activities**: Real-time timer display via Live Activity extension
- **Analytics**: Comprehensive session tracking and user behavior analysis

### User Management
- **Authentication**: Supabase-based user authentication
- **Profile Management**: User settings, preferences, and data sync
- **Social Features**: Friend system, leaderboards, and social interactions

### Premium Features
- **Subscription Tiers**: Multiple premium levels with different features
- **In-App Purchases**: StoreKit integration for subscription management
- **Feature Gating**: Premium feature access control

## 🔧 Flutter Migration Notes

### Architecture Mapping
- **SwiftUI Views** → **Flutter Widgets**: Convert SwiftUI views to Flutter widgets
- **Combine Publishers** → **Streams**: Replace Combine with Dart streams for reactive programming
- **Core Data** → **SQLite/Hive**: Use SQLite or Hive for local data persistence
- **Supabase Swift** → **Supabase Dart**: Use Supabase Dart client for backend integration

### Key Considerations
1. **App Blocking**: iOS FamilyControls has no direct Flutter equivalent - consider platform-specific implementations
2. **Live Activities**: iOS-specific feature - implement using Flutter platform channels or native modules
3. **Push Notifications**: Use Firebase Cloud Messaging (FCM) for cross-platform notifications
4. **In-App Purchases**: Use `in_app_purchase` package for StoreKit equivalent functionality

### State Management
- **MVVM Pattern**: Can be implemented using Provider, Riverpod, or Bloc pattern
- **Reactive Programming**: Use Dart streams and reactive programming libraries
- **Local Storage**: Implement using shared_preferences, SQLite, or Hive

## 🚀 Development Workflow

### Building
1. Open `Shut Up Timer.xcodeproj` in Xcode
2. Configure signing and capabilities
3. Set up environment variables in `Config.swift`
4. Build and run on device or simulator

### Testing
- **Unit Tests**: `Shut Up TimerTests/` directory
- **UI Tests**: `Shut Up TimerUITests/` directory
- **Manual Testing**: Test timer functionality, app blocking, and live activities

### Deployment
- Configure App Store Connect settings
- Set up production environment in `Config.swift`
- Archive and upload to App Store Connect

## 📱 Platform-Specific Features

### iOS-Only Features
- **FamilyControls**: App blocking and screen time management
- **Live Activities**: Dynamic Island and lock screen widgets
- **Core Data**: Native iOS data persistence
- **StoreKit**: Native in-app purchase handling

### Cross-Platform Considerations
- **Authentication**: Supabase provides cross-platform auth
- **Backend APIs**: FastAPI backend can serve multiple platforms
- **Analytics**: Can be implemented using Firebase Analytics
- **Push Notifications**: FCM works across platforms

---

**Note**: This directory contains the core business logic and UI components. When migrating to Flutter, focus on maintaining the same user experience while adapting to Flutter's widget system and state management patterns.
