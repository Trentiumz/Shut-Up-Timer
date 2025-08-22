# Shut Up Timer - iOS App

A productivity-focused iOS app that helps users stay focused by implementing strict timer mechanisms with app blocking and motivational features.

## 🎯 Overview

Shut Up Timer is a SwiftUI-based iOS application that combines timer functionality with app blocking capabilities to help users maintain focus during work sessions. The app features:

- **Strict Timer System**: No-leave and app-blocking timer modes
- **Live Activities**: Real-time timer display on lock screen and Dynamic Island
- **Social Features**: Friend system with QR codes and leaderboards
- **Motivational Elements**: Roast system and catchphrases
- **Analytics**: Comprehensive tracking of user behavior and session data
- **Subscription Management**: In-app purchases and premium features

## 🏗️ Architecture

The app follows MVVM (Model-View-ViewModel) architecture with the following key components:

### Core Architecture
- **SwiftUI Views**: Modern declarative UI framework
- **Combine**: Reactive programming for data flow
- **Core Data**: Local data persistence
- **Supabase**: Backend database and authentication
- **FastAPI**: Custom backend services

### Key Technologies
- **FamilyControls**: App blocking and screen time management
- **UserNotifications**: Local and remote notifications
- **Live Activities**: Dynamic Island and lock screen widgets
- **StoreKit**: In-app purchase handling

## 📁 Project Structure

```
Shut Up Timer/
├── 📱 Main App (Shut Up Timer/)
│   ├── Views/           # SwiftUI view components
│   ├── Models/          # Data models and Core Data
│   ├── ViewModels/      # MVVM view models
│   ├── API/            # Backend API clients
│   ├── Modules/        # Feature-specific modules
│   ├── Tokens/         # Design system tokens
│   └── Delegate/       # App delegates and managers
├── 🔔 Live Activity Extension (Procrastination_Countdown_Activity/)
├── 📊 Device Activity Report Extension
├── 🔔 Notification Service Extension
└── 🧪 Test Targets
```

## 🚀 Key Features

### Timer System
- **No-Leave Mode**: Prevents leaving the app during timer
- **App-Block Mode**: Blocks other apps during timer
- **Pomodoro Integration**: Built-in Pomodoro technique support
- **Task Selection**: Todo integration for focused work

### Social Features
- **Friend System**: Add friends via QR codes
- **Leaderboards**: Compare productivity with friends
- **Roast System**: Motivational messages when users fail

### Analytics & Insights
- **Session Tracking**: Detailed session analytics
- **Productivity Metrics**: IQ scoring and time tracking
- **Category Analysis**: Track focus areas and productivity patterns

### Premium Features
- **Subscription Tiers**: Multiple premium levels
- **Advanced Analytics**: Detailed insights and reports
- **Customization**: Enhanced personalization options

## 🔧 Development Setup

### Requirements
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Configuration
- Update `Config.swift` with your API endpoints
- Configure Supabase credentials
- Set up StoreKit configuration for testing

### Key Dependencies
- Supabase Swift SDK
- Combine framework
- Core Data
- FamilyControls
- UserNotifications

## 📱 Extensions

### Live Activity Extension
- Real-time timer display on Dynamic Island
- Lock screen widget integration
- Background updates and notifications

### Device Activity Report
- Screen time and app usage analytics
- Privacy-focused activity tracking
- Family sharing integration

### Notification Service
- Remote notification processing
- Silent push handling
- Background task management

## 🔄 Migration to Flutter

This documentation is designed to facilitate migration to Flutter by providing:

1. **Clear Architecture Mapping**: Each folder's README explains the iOS implementation
2. **Feature Breakdown**: Detailed explanations of each feature's functionality
3. **Data Flow Documentation**: How data moves through the app
4. **API Integration Details**: Backend service implementations
5. **State Management Patterns**: iOS-specific patterns that need Flutter equivalents

## 📄 License

See [LICENSE](LICENSE) file for details.

---

**Note**: This app uses strict timer mechanisms and app blocking features. Ensure compliance with App Store guidelines and user privacy requirements when implementing similar functionality in Flutter. 