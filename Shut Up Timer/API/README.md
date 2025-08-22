# API Directory

This directory contains all backend API clients and network layer implementations for the Shut Up Timer app. The API layer handles communication with external services including Supabase, custom FastAPI backend, and third-party integrations.

## 🏗️ Architecture

The API layer follows a client-based architecture with:
- **FastAPI Client**: Custom backend service integration
- **Supabase Client**: Database and authentication services
- **API Models**: Request/response data structures
- **Error Handling**: Centralized error management and retry logic

## 📁 Directory Structure

```
API/
├── FastAPI.swift           # Main FastAPI client implementation
├── FastAPILiveActivity.swift  # Live activity API integration
└── FastAPIRoasts.swift     # Roast system API client
```

## 🎯 API Clients

### FastAPI Client (`FastAPI.swift`)
Main backend service client for core app functionality:
- **User Management**: Authentication, profile updates, user data sync
- **Session Management**: Timer session storage and retrieval
- **Analytics**: User behavior tracking and metrics
- **Social Features**: Friend system, leaderboards, social interactions
- **Subscription Management**: Premium feature access and billing

### Live Activity API (`FastAPILiveActivity.swift`)
Specialized client for Live Activity integration:
- **Real-time Updates**: Dynamic Island and lock screen updates
- **Background Sync**: Live activity data synchronization
- **State Management**: Live activity state persistence
- **Notification Integration**: Push notification handling

### Roast API (`FastAPIRoasts.swift`)
Motivational system API client:
- **Roast Generation**: Dynamic motivational message creation
- **Content Management**: Roast content updates and personalization
- **User Feedback**: Roast effectiveness tracking
- **A/B Testing**: Roast performance optimization

## 🔄 API Integration

### Authentication Flow
1. **Supabase Auth**: Primary authentication through Supabase
2. **Token Management**: JWT token handling and refresh
3. **Session Persistence**: User session state management
4. **Secure Storage**: Credential storage and retrieval

### Data Synchronization
- **Offline-First**: Local data storage with backend sync
- **Conflict Resolution**: Data merging and conflict handling
- **Real-time Updates**: WebSocket connections for live data
- **Batch Operations**: Efficient bulk data operations

### Error Handling
- **Network Errors**: Connection timeout and retry logic
- **Authentication Errors**: Token refresh and re-authentication
- **Data Validation**: Request/response validation
- **User Feedback**: Error messages and recovery options

## 🎯 Key Features

### User Management
- **Registration/Login**: User account creation and authentication
- **Profile Updates**: User information and preferences
- **Data Export**: User data backup and export
- **Account Deletion**: User account removal and data cleanup

### Session Analytics
- **Session Storage**: Timer session data persistence
- **Analytics Tracking**: User behavior and productivity metrics
- **Performance Insights**: Productivity analysis and recommendations
- **Goal Tracking**: User goal progress and achievements

### Social Features
- **Friend System**: User connections and friend management
- **Leaderboards**: Competitive productivity rankings
- **Social Sharing**: Achievement sharing and social interactions
- **Community Features**: User community and engagement

### Premium Features
- **Subscription Management**: Premium tier handling
- **Feature Gating**: Premium feature access control
- **Billing Integration**: Payment processing and receipt validation
- **Trial Management**: Free trial handling and conversion

## 🔧 Flutter Migration Notes

### HTTP Client Mapping
- **URLSession** → **Dio/HTTP**: Replace URLSession with Dio or http package
- **Combine Publishers** → **Streams**: Use Dart streams for async operations
- **JSON Decoding** → **JSON Serialization**: Use `json_annotation` for model serialization
- **Error Handling** → **Exception Handling**: Implement proper exception handling

### Key Considerations

#### HTTP Client Setup
1. **Base URL Configuration**: Set up environment-specific base URLs
2. **Interceptors**: Implement request/response interceptors for logging and auth
3. **Timeout Configuration**: Set appropriate timeout values
4. **Retry Logic**: Implement exponential backoff for failed requests

#### Authentication
1. **Token Management**: Store and refresh JWT tokens
2. **Secure Storage**: Use `flutter_secure_storage` for sensitive data
3. **Auto-refresh**: Implement automatic token refresh
4. **Logout Handling**: Proper cleanup on user logout

#### Data Models
1. **JSON Serialization**: Use `json_annotation` for model serialization
2. **Type Safety**: Ensure type-safe API responses
3. **Null Safety**: Handle nullable fields properly
4. **Validation**: Implement request/response validation

### Recommended Flutter Packages
- **HTTP Client**: `dio` for advanced HTTP functionality
- **JSON Serialization**: `json_annotation` and `json_serializable`
- **Secure Storage**: `flutter_secure_storage` for sensitive data
- **Local Storage**: `shared_preferences` for simple data
- **WebSocket**: `web_socket_channel` for real-time communication

### API Client Structure
```dart
// Example Flutter API client structure
class FastAPIClient {
  final Dio _dio;
  final String _baseUrl;
  
  FastAPIClient({required String baseUrl}) 
    : _baseUrl = baseUrl,
      _dio = Dio(BaseOptions(baseUrl: baseUrl));
  
  Future<User> authenticate(String email, String password) async {
    // Implementation
  }
  
  Future<void> syncSession(Session session) async {
    // Implementation
  }
}
```

## 🚀 Development Guidelines

### API Design
1. **RESTful Principles**: Follow REST API design principles
2. **Consistent Naming**: Use consistent endpoint naming conventions
3. **Versioning**: Implement API versioning strategy
4. **Documentation**: Maintain comprehensive API documentation

### Error Handling
- **HTTP Status Codes**: Proper use of HTTP status codes
- **Error Messages**: Clear and actionable error messages
- **Retry Logic**: Implement smart retry strategies
- **User Feedback**: Provide meaningful error feedback to users

### Performance
- **Caching**: Implement appropriate caching strategies
- **Batch Operations**: Use batch endpoints for bulk operations
- **Pagination**: Implement pagination for large datasets
- **Compression**: Use compression for large payloads

### Security
- **HTTPS**: Always use HTTPS for API communication
- **Token Security**: Secure token storage and transmission
- **Input Validation**: Validate all API inputs
- **Rate Limiting**: Implement rate limiting for API endpoints

## 📱 Platform Considerations

### iOS-Specific Features
- **URLSession**: Native iOS networking framework
- **Combine**: Reactive programming for async operations
- **Keychain**: Secure credential storage
- **Background App Refresh**: Background API synchronization

### Cross-Platform Migration
- **HTTP Client**: Dio provides cross-platform HTTP functionality
- **Secure Storage**: Flutter secure storage works on both platforms
- **WebSocket**: WebSocket support across platforms
- **Local Storage**: Shared preferences work on both platforms

### Backend Compatibility
- **Supabase**: Supabase provides cross-platform SDKs
- **FastAPI**: Backend can serve multiple platforms
- **Authentication**: JWT-based auth works across platforms
- **Real-time**: WebSocket connections work on both platforms

## 🔧 Testing

### API Testing
- **Unit Tests**: Test API client methods
- **Integration Tests**: Test API integration with backend
- **Mock Responses**: Use mock data for testing
- **Error Scenarios**: Test error handling and edge cases

### Network Testing
- **Offline Scenarios**: Test offline behavior and caching
- **Slow Connections**: Test performance on slow networks
- **Timeout Handling**: Test timeout and retry logic
- **Security Testing**: Test authentication and authorization

---

**Note**: When migrating to Flutter, focus on maintaining the same API contracts and data structures while adapting to Flutter's HTTP client patterns. Pay special attention to authentication flows and real-time data synchronization.
