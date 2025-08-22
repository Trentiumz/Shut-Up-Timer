# ViewModels Directory

This directory contains the ViewModels that implement the MVVM (Model-View-ViewModel) pattern for the Shut Up Timer app. ViewModels handle the business logic, state management, and data transformation between the Models and Views.

## 🏗️ Architecture

The ViewModels follow the MVVM pattern with:
- **Separation of Concerns**: Clear separation between data, business logic, and UI
- **Observable State**: Reactive state management using Combine
- **Data Binding**: Automatic UI updates when data changes
- **Testability**: Isolated business logic for easy testing

## 📁 Directory Structure

```
ViewModels/
├── MVVM.swift           # Base MVVM protocol and utilities
└── TimerViewModel.swift # Timer-specific view model
```

## 🎯 ViewModel Components

### Base MVVM (`MVVM.swift`)
Provides the foundation for all ViewModels in the app:

**Core Features:**
- **Base Protocol**: Common ViewModel interface and behavior
- **State Management**: Observable state patterns
- **Lifecycle Management**: ViewModel lifecycle handling
- **Error Handling**: Standardized error handling patterns

**Key Responsibilities:**
- **Data Transformation**: Transform model data for UI consumption
- **Business Logic**: Encapsulate business rules and logic
- **State Updates**: Manage UI state and updates
- **User Actions**: Handle user interactions and commands

### Timer ViewModel (`TimerViewModel.swift`)
Specialized ViewModel for timer functionality:

**Timer Management:**
- **Session State**: Track current timer session state
- **Timer Controls**: Start, pause, stop, and reset functionality
- **Time Tracking**: Accurate time measurement and display
- **Session Persistence**: Save and restore timer sessions

**Business Logic:**
- **Timer Validation**: Validate timer settings and constraints
- **Session Analytics**: Track session metrics and performance
- **Goal Integration**: Integrate with user goals and objectives
- **App Blocking**: Coordinate with app blocking functionality

## 🔄 Data Flow

### MVVM Pattern Flow
1. **Model Updates**: Core Data or API updates trigger model changes
2. **ViewModel Processing**: ViewModels process and transform model data
3. **State Updates**: Observable state updates trigger UI refresh
4. **User Actions**: User interactions flow through ViewModels to models

### State Management
- **ObservableObject**: ViewModels conform to ObservableObject for reactive updates
- **@Published Properties**: Properties that trigger UI updates when changed
- **Combine Publishers**: Reactive data flow and state management
- **State Synchronization**: Keep UI state synchronized with underlying data

### Data Binding
- **Automatic Updates**: UI automatically updates when ViewModel state changes
- **Bidirectional Binding**: Two-way data binding for form inputs
- **Validation**: Real-time validation and error handling
- **Loading States**: Handle loading, success, and error states

## 🎯 Key Features

### Timer Functionality
- **Session Management**: Create, update, and manage timer sessions
- **Time Tracking**: Accurate time measurement with background support
- **State Transitions**: Handle timer state changes (active, paused, completed)
- **Goal Integration**: Link timer sessions to user goals

### User Interaction
- **Command Pattern**: Handle user actions and commands
- **Validation**: Validate user inputs and actions
- **Error Handling**: Provide meaningful error messages
- **Loading States**: Show appropriate loading indicators

### Data Processing
- **Data Transformation**: Transform model data for UI display
- **Formatting**: Format data for user-friendly display
- **Calculations**: Perform business calculations and analytics
- **Caching**: Cache frequently accessed data

## 🔧 Flutter Migration Notes

### State Management Mapping
- **ObservableObject** → **ChangeNotifier**: Use ChangeNotifier for state management
- **@Published** → **ValueNotifier**: Use ValueNotifier for reactive properties
- **Combine Publishers** → **Streams**: Use Dart streams for reactive programming
- **EnvironmentObject** → **Provider/InheritedWidget**: Use dependency injection

### Key Considerations

#### State Management Architecture
1. **Provider Pattern**: Use Provider for dependency injection and state management
2. **Riverpod**: Consider Riverpod for more advanced state management
3. **Bloc Pattern**: Use Bloc for complex state management scenarios
4. **Local State**: Use StatefulWidget for component-specific state

#### Data Binding
1. **StreamBuilder**: Use StreamBuilder for reactive UI updates
2. **ValueListenableBuilder**: Use ValueListenableBuilder for simple state updates
3. **Consumer**: Use Consumer for Provider-based state management
4. **Selector**: Use Selector for optimized rebuilds

#### Business Logic
1. **Service Classes**: Move business logic to service classes
2. **Repository Pattern**: Use repository pattern for data access
3. **Use Cases**: Implement use cases for complex business operations
4. **Validation**: Implement validation logic in ViewModels

### Recommended Flutter Structure
```dart
// Example Flutter ViewModel structure
class TimerViewModel extends ChangeNotifier {
  Timer? _timer;
  int _currentTime = 0;
  TimerState _state = TimerState.idle;
  
  int get currentTime => _currentTime;
  TimerState get state => _state;
  
  void startTimer() {
    _state = TimerState.running;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _currentTime++;
      notifyListeners();
    });
  }
  
  void stopTimer() {
    _timer?.cancel();
    _state = TimerState.stopped;
    notifyListeners();
  }
}
```

## 🚀 Development Guidelines

### ViewModel Design
1. **Single Responsibility**: Each ViewModel should have a clear, focused purpose
2. **Testability**: Design ViewModels to be easily testable
3. **Dependency Injection**: Use dependency injection for external dependencies
4. **Error Handling**: Implement comprehensive error handling

### State Management
- **Immutable State**: Use immutable state where possible
- **State Updates**: Batch state updates for better performance
- **State Validation**: Validate state changes before applying
- **State Persistence**: Persist important state when needed

### Performance Considerations
- **Efficient Updates**: Only update UI when necessary
- **Memory Management**: Properly dispose of resources and subscriptions
- **Lazy Loading**: Load data on-demand to improve performance
- **Caching**: Cache frequently accessed data

## 📱 Platform Considerations

### iOS-Specific Features
- **Combine**: Native iOS reactive programming framework
- **ObservableObject**: SwiftUI's observable object protocol
- **@Published**: Property wrapper for reactive properties
- **EnvironmentObject**: SwiftUI's dependency injection

### Cross-Platform Migration
- **State Management**: Provider/Riverpod works across platforms
- **Reactive Programming**: Dart streams work on both platforms
- **Dependency Injection**: Provider works on both platforms
- **Testing**: ViewModels can be tested consistently across platforms

### Architecture Patterns
- **MVVM**: Can be implemented consistently across platforms
- **Repository Pattern**: Works well on both platforms
- **Service Layer**: Can be shared between platforms
- **Validation Logic**: Can be implemented consistently

## 🔧 Testing

### ViewModel Testing
- **Unit Tests**: Test ViewModel business logic
- **State Testing**: Test state changes and updates
- **Error Testing**: Test error handling scenarios
- **Integration Testing**: Test ViewModel integration with models

### Testing Strategy
- **Mock Dependencies**: Use mocks for external dependencies
- **Test Coverage**: Maintain high test coverage for ViewModels
- **Test Data**: Use consistent test data across tests
- **Performance Testing**: Test ViewModel performance under load

### Testing Tools
- **Mockito**: For creating mocks and stubs
- **Test Widgets**: For testing Flutter widgets
- **Integration Tests**: For testing complete user flows
- **Golden Tests**: For visual regression testing

---

**Note**: When migrating to Flutter, focus on maintaining the same business logic and state management patterns while adapting to Flutter's state management solutions. Pay special attention to reactive programming patterns and dependency injection.
