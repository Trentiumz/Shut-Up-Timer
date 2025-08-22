# Models Directory

This directory contains all data models, Core Data entities, and business logic for the Shut Up Timer app. The models define the data structure, relationships, and core business rules that drive the application.

## 🏗️ Architecture

The models follow a layered architecture with:
- **Core Data Entities**: Persistent data models with relationships
- **Business Logic Models**: Domain-specific models and extensions
- **Data Wrappers**: Observable wrappers for reactive data flow
- **External Models**: Third-party integrations and API models

## 📁 Directory Structure

```
Models/
├── Model.xcdatamodeld/    # Core Data model definition
├── Timer/                 # Timer-specific models and entities
├── Session+Extensions.swift    # Session business logic extensions
├── CurUser.swift          # Current user model and state
├── SettingsModel.swift    # User settings and preferences
├── Roasts.swift           # Roast system models
├── LiveActivitySettings.swift  # Live activity configuration
├── SessionsWrapper.swift  # Session data wrapper
├── Goal+Extensions.swift  # Goal-related business logic
├── LBEntry.swift          # Leaderboard entry model
├── ClientNotification.swift # Notification data models
└── ImageLoader.swift      # Image loading and caching
```

## 🎯 Core Data Entities

### Session Entity
The central data model for timer sessions:
- **Core Properties**: `startTime`, `endTime`, `plannedTime`, `timeLocked`
- **Relationships**: Links to goals, categories, and user data
- **Business Logic**: Session validation, duration calculations, and analytics

### User Entity
User profile and authentication data:
- **Profile Data**: Username, email, subscription status
- **Preferences**: App settings, notification preferences
- **Social Data**: Friends, leaderboard rankings, achievements

### Goal Entity
User-defined goals and objectives:
- **Goal Properties**: Title, description, target time, completion status
- **Categories**: Goal categorization for analytics
- **Progress Tracking**: Goal completion metrics and history

## 🔄 Data Flow

### Core Data Stack
1. **PersistenceController**: Manages Core Data stack and context
2. **SessionLoader**: Observable wrapper for session data
3. **Model Extensions**: Business logic applied to Core Data entities
4. **View Models**: Consume model data for UI presentation

### Data Synchronization
- **Local Storage**: Core Data for offline-first data persistence
- **Backend Sync**: Supabase integration for cloud data storage
- **Real-time Updates**: Combine publishers for reactive data flow
- **Conflict Resolution**: Data merging and conflict handling

## 🎯 Key Models

### Session Management
- **Session**: Core timer session entity with start/end times
- **Session+Extensions**: Business logic for session calculations
- **SessionsWrapper**: Observable wrapper for session collections
- **SessionStatus**: Enum for session states (active, completed, failed)

### User Management
- **CurUser**: Current user state and authentication
- **SettingsModel**: User preferences and app configuration
- **LiveActivitySettings**: Live activity configuration and state

### Social Features
- **Roasts**: Motivational message system
- **LBEntry**: Leaderboard entries and rankings
- **Friend System**: User connections and social interactions

### Notifications
- **ClientNotification**: Local notification data models
- **NotificationManager**: Notification scheduling and management

## 🔧 Business Logic

### Session Analytics
- **Duration Calculations**: Actual vs planned time tracking
- **Success Metrics**: Completion rates and failure analysis
- **Category Analysis**: Focus area tracking and insights
- **IQ Scoring**: Productivity scoring algorithm

### Goal Management
- **Goal Creation**: User-defined objectives and targets
- **Progress Tracking**: Goal completion metrics
- **Category Organization**: Goal categorization system
- **Achievement System**: Milestone tracking and rewards

### Social Features
- **Roast Generation**: Motivational message system
- **Leaderboard Rankings**: Competitive productivity tracking
- **Friend Management**: Social connections and sharing

## 🔧 Flutter Migration Notes

### Data Persistence Mapping
- **Core Data** → **SQLite/Hive**: Replace Core Data with SQLite or Hive
- **NSManagedObject** → **Custom Classes**: Convert Core Data entities to Dart classes
- **NSPredicate** → **SQL Queries**: Replace Core Data queries with SQL
- **NSFetchRequest** → **Database Queries**: Use database query builders

### State Management
- **ObservableObject** → **ChangeNotifier/Provider**: Use Flutter state management
- **Combine Publishers** → **Streams**: Replace Combine with Dart streams
- **@Published** → **ValueNotifier**: Use ValueNotifier for reactive properties
- **EnvironmentObject** → **Provider/InheritedWidget**: Implement dependency injection

### Key Considerations

#### Database Design
1. **Schema Migration**: Plan for database schema evolution
2. **Relationships**: Implement foreign key relationships in SQLite
3. **Indexing**: Optimize database performance with proper indexing
4. **Data Validation**: Implement business rule validation in Dart

#### Business Logic
1. **Model Extensions** → **Service Classes**: Move business logic to service classes
2. **Data Wrappers** → **Repository Pattern**: Use repository pattern for data access
3. **Validation Logic** → **Model Validation**: Implement validation in model classes
4. **Calculations** → **Utility Functions**: Extract calculation logic to utility functions

#### Data Synchronization
1. **Offline-First**: Maintain offline-first architecture
2. **Conflict Resolution**: Implement data merging strategies
3. **Real-time Updates**: Use WebSockets or polling for real-time data
4. **Caching Strategy**: Implement efficient data caching

### Recommended Flutter Packages
- **SQLite**: `sqflite` for local database
- **State Management**: `provider` or `riverpod`
- **HTTP Client**: `dio` or `http`
- **Local Storage**: `shared_preferences` for simple data
- **Reactive Programming**: `rxdart` for advanced stream operations

## 🚀 Development Guidelines

### Model Design
1. **Single Responsibility**: Each model should have a clear, focused purpose
2. **Immutability**: Use immutable data structures where possible
3. **Validation**: Include data validation in model classes
4. **Documentation**: Document complex business logic and relationships

### Performance Considerations
- **Lazy Loading**: Load data on-demand to improve performance
- **Caching**: Implement efficient caching strategies
- **Batch Operations**: Use batch operations for bulk data changes
- **Memory Management**: Properly dispose of resources and subscriptions

### Testing
- **Unit Tests**: Test business logic and data transformations
- **Integration Tests**: Test data persistence and synchronization
- **Mock Data**: Use mock data for testing and development
- **Data Validation**: Test data validation and error handling

## 📱 Platform Considerations

### iOS-Specific Features
- **Core Data**: Native iOS data persistence framework
- **NSManagedObject**: Core Data entity base class
- **NSPredicate**: Core Data query language
- **NSFetchRequest**: Core Data fetch request system

### Cross-Platform Migration
- **Database**: SQLite provides cross-platform data persistence
- **State Management**: Provider/Riverpod works across platforms
- **HTTP Client**: Dio provides cross-platform HTTP functionality
- **Local Storage**: Shared preferences work on both platforms

---

**Note**: When migrating to Flutter, focus on maintaining the same data relationships and business logic while adapting to Flutter's data persistence patterns. Pay special attention to data synchronization and offline-first capabilities.
