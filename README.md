# Shut-Up-Timer
Shut up timer is an iOS app made for people who want a more humorous (and aggressive) approach to studying

### Project Structure
```
Shut Up Timer/
├── Models/                  # Core data models and business logic
├── ViewModels/             # View-specific state management and business logic
├── Views/                  # UI components and screens
│   ├── Landing/           # Main app screens and navigation
│   │   ├── Friends/       # Friend management and social features
│   │   ├── Settings/      # App settings and configuration
│   │   ├── Leaderboard/   # User rankings and achievements
│   │   ├── Onboarding/    # First-time user experience
│   │   ├── Disappointment/# User progress and motivation
│   │   ├── Home/         # Main dashboard and timer interface
│   │   └── TopBarView.swift # Common navigation header
│   ├── Common/            # Reusable UI components
│   └── Timer/             # Timer-specific views and controls
├── External Models/        # Third-party model integrations
├── Assets.xcassets/        # App images, colors, and assets
├── Preview Content/        # SwiftUI preview resources
├── AppRoute.swift         # App routing and navigation logic
├── AppRouter.swift        # Navigation state management
├── ContentView.swift      # Main app container view
├── CredManager.swift      # Authentication and credentials management
├── Shut_Up_TimerApp.swift # App entry point and configuration
└── Utilities.swift        # Helper functions and utilities
```

* **Models/**: Core data models and business logic for the application
* **ViewModels/**: View-specific state management and business logic
* **Views/**: UI components and screens that make up the app interface
  * **Landing/**: Contains all main app screens and navigation components
    * **Friends/**: Friend management, social features, and user connections
    * **Settings/**: App configuration, preferences, and user settings
    * **Leaderboard/**: User rankings, achievements, and competitive features
    * **Onboarding/**: First-time user experience and initial setup
    * **Disappointment/**: User progress tracking and motivation features
    * **Home/**: Main dashboard and primary timer interface
    * **TopBarView.swift**: Common navigation header used across screens
  * **Common/**: Reusable UI components shared across the app
  * **Timer/**: Timer-specific views and control interfaces
* **External Models/**: Third-party model integrations and external data structures
* **Assets.xcassets/**: Contains all app images, colors, and other visual assets
* **Preview Content/**: Resources used for SwiftUI previews during development
* **AppRoute.swift**: Defines the app's routing structure and navigation paths
* **AppRouter.swift**: Manages navigation state and view transitions
* **ContentView.swift**: Main container view that hosts the app's primary interface
* **CredManager.swift**: Handles authentication, user credentials, and secure storage
* **Shut_Up_TimerApp.swift**: App entry point, configuration, and initialization
* **Utilities.swift**: Helper functions and utility methods used throughout the app

### General Notes
* All data that need to be synced up between views (e.g. sessions and settings) should be in Models. These models are then shared to all the views from Shut_Up_TimerApp.swift so that any time something updates, the Views will refresh with the new data. 
* We follow an MVVM architection, but since the app isn't all that complex, we only really need to use it for the Timer. The AppRouter manages the ViewModel, and we call its functions to initialize and set up the ViewModel. 