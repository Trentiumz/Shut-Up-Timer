# Views Directory

This directory contains all SwiftUI view components and screens that make up the user interface of the Shut Up Timer app. The views follow a modular structure organized by feature and functionality.

## 🏗️ Architecture

The views follow SwiftUI's declarative UI pattern with:
- **ObservableObject**: For state management and data binding
- **EnvironmentObject**: For dependency injection of shared services
- **Navigation**: Managed through `AppRouter` for centralized routing
- **Reusable Components**: Common UI elements in the `Common/` subdirectory

## 📁 Directory Structure

```
Views/
├── Landing/           # Main app screens and navigation
├── Timer/            # Timer-specific views and controls
├── Common/           # Reusable UI components
├── Feedback/         # User feedback and rating views
├── Login/            # Authentication and onboarding views
├── Notifications/    # Notification management views
└── Subscription/     # Subscription and payment views
```

## 🎯 View Categories

### Landing Views (`Landing/`)
Main app screens that users interact with most frequently:
- **Home**: Dashboard with timer controls and session overview
- **Friends**: Social features, friend management, and QR code sharing
- **Settings**: App configuration and user preferences
- **Leaderboard**: User rankings and competitive features
- **Onboarding**: First-time user experience and setup
- **Disappointment**: Progress tracking and motivational features

### Timer Views (`Timer/`)
Core timer functionality and session management:
- **TimerView**: Main timer interface with start/stop controls
- **TaskSelection**: Todo integration for focused work sessions
- **Session Management**: Timer state handling and transitions
- **Live Activity Integration**: Real-time timer display coordination

### Common Views (`Common/`)
Reusable UI components shared across the app:
- **Buttons**: Custom button styles and interactions
- **Cards**: Consistent card layouts and styling
- **Modals**: Popup dialogs and overlay components
- **Navigation**: Common navigation patterns and headers

### Feature-Specific Views
- **Feedback**: User rating, reviews, and feedback collection
- **Login**: Authentication flows and user onboarding
- **Notifications**: Notification preferences and management
- **Subscription**: In-app purchase flows and premium features

## 🔄 Navigation Flow

### App Router Integration
All views are connected through the `AppRouter` which manages:
- **Route Definitions**: Centralized route mapping in `AppRoute.swift`
- **State Transitions**: View state changes and navigation logic
- **Deep Linking**: URL-based navigation and external app integration

### Navigation Patterns
1. **Tab-Based Navigation**: Main app sections (Home, Friends, Settings)
2. **Modal Presentations**: Overlay views for focused interactions
3. **Push Navigation**: Hierarchical navigation within sections
4. **Sheet Presentations**: Bottom sheet modals for quick actions

## 🎨 UI Design System

### Design Tokens
Views reference design tokens from the `Tokens/` directory:
- **Colors**: Consistent color palette and theming
- **Typography**: Font families, sizes, and weights
- **Spacing**: Standardized margins, padding, and layout spacing
- **Images**: Icon and image assets with consistent naming

### Responsive Design
- **Adaptive Layouts**: Support for different screen sizes
- **Dynamic Type**: Accessibility-friendly text scaling
- **Dark Mode**: Automatic theme switching support
- **Safe Areas**: Proper handling of device-specific safe areas

## 🔧 Flutter Migration Notes

### Widget Mapping
- **SwiftUI Views** → **Flutter Widgets**: Convert SwiftUI views to equivalent Flutter widgets
- **ObservableObject** → **ChangeNotifier/Provider**: Use Flutter state management patterns
- **EnvironmentObject** → **Provider/InheritedWidget**: Implement dependency injection
- **NavigationView** → **Navigator**: Use Flutter's navigation system

### Key Considerations

#### State Management
- **MVVM Pattern**: Implement using Provider, Riverpod, or Bloc
- **Reactive UI**: Use StreamBuilder or ValueListenableBuilder for reactive updates
- **Local State**: Use StatefulWidget for component-specific state

#### Navigation
- **AppRouter** → **GoRouter/Navigation 2.0**: Use Flutter's modern navigation
- **Route Definitions**: Define routes in a centralized router configuration
- **Deep Linking**: Implement using GoRouter or custom route handling

#### UI Components
- **SwiftUI Modifiers** → **Flutter Widgets**: Convert SwiftUI modifiers to Flutter widget properties
- **Custom Views** → **Custom Widgets**: Create reusable Flutter widgets for common components
- **Animations** → **AnimationController**: Use Flutter's animation system

### Platform-Specific Features
1. **Live Activities**: iOS-specific - implement using platform channels
2. **Dynamic Island**: iOS-specific - consider alternative UI patterns for Android
3. **Haptic Feedback**: Use `flutter_haptic_feedback` package
4. **Biometric Auth**: Use `local_auth` package for cross-platform authentication

## 🚀 Development Guidelines

### View Creation
1. **Single Responsibility**: Each view should have a clear, focused purpose
2. **Reusability**: Extract common patterns into reusable components
3. **Accessibility**: Include proper accessibility labels and hints
4. **Performance**: Use lazy loading and efficient state management

### Testing
- **Unit Tests**: Test view models and business logic
- **Widget Tests**: Test individual view components
- **Integration Tests**: Test complete user flows
- **Accessibility Tests**: Ensure proper accessibility support

### Code Organization
- **Feature-Based**: Group related views in feature directories
- **Common Components**: Extract shared UI elements to `Common/`
- **Consistent Naming**: Use descriptive, consistent naming conventions
- **Documentation**: Include comments for complex UI logic

## 📱 Platform Considerations

### iOS-Specific Features
- **SwiftUI**: Native iOS UI framework with declarative syntax
- **Combine**: Reactive programming for data binding
- **Core Data**: Native iOS data persistence
- **FamilyControls**: App blocking and screen time management

### Cross-Platform Migration
- **Widget System**: Flutter's widget tree replaces SwiftUI view hierarchy
- **State Management**: Provider/Riverpod replaces Combine publishers
- **Navigation**: GoRouter replaces AppRouter navigation system
- **Local Storage**: SQLite/Hive replaces Core Data

---

**Note**: When migrating to Flutter, focus on maintaining the same user experience while adapting to Flutter's widget system. Pay special attention to platform-specific features that may need alternative implementations or platform channels.
