import SwiftUI
import FamilyControls
import ManagedSettings

class AppBlocker {
    // ManagedSettings store for app blocking
    private let store = ManagedSettingsStore()
    
    // Timer for checking permissions
    private var permissionTimer: Timer?
    
    // Closure to call when the timer should fail
    private let failTimer: () -> Void
    
    /// Initializes the AppBlocker with a failure callback
    /// - Parameter failTimer: Closure to call when permissions are revoked or blocking fails
    init(failTimer: @escaping () -> Void) {
        self.failTimer = failTimer
    }
    
    deinit {
        destroy();
    }
    
    // MARK: - App Blocking Functions
    
    /// Starts blocking apps using the settings
    func startBlocking() {
        // Check permissions first
        guard checkPermissions() else {
            print("Cannot start blocking: FamilyControls permissions not granted")
            failTimer()
            return
        }
        
        // Get the current settings
        let settings = SettingsLoader.loadSettings()
        
        // Block the selected apps
        store.shield.applications = settings.defaultBlockedApps.applicationTokens
        store.shield.applicationCategories = .specific(settings.defaultBlockedApps.categoryTokens)
        
        print("Started blocking apps: \(settings.defaultBlockedApps.applicationTokens.count) apps, \(settings.defaultBlockedApps.categoryTokens.count) categories")
        
        // Start monitoring permissions
        startPermissionTimer()
    }
    
    /// Stops blocking apps
    func stopBlocking() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil

        stopPermissionTimer()
        
        print("Stopped blocking apps")
    }
    
    /// Checks if FamilyControls permissions are still granted
    func checkPermissions() -> Bool {
        let authStatus = FamilyControls.AuthorizationCenter.shared.authorizationStatus
        return authStatus == .approved
    }
    
    /// Starts the permission checking timer
    private func startPermissionTimer() {
        permissionTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            if !self.checkPermissions() {
                print("FamilyControls permissions revoked, failing timer")
                self.failTimer()
            }
        }
    }
    
    /// Stops the permission checking timer
    private func stopPermissionTimer() {
        permissionTimer?.invalidate()
        permissionTimer = nil
    }
    
    /// Completely destroys the app blocker and cleans up all resources
    func destroy() {
        stopBlocking()
        stopPermissionTimer()
    }
} 