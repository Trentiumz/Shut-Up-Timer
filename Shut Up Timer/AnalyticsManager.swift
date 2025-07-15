import Foundation
import FirebaseAnalytics

class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() {}
    
    // MARK: - User Identification
    func setUserId(_ userId: String) {
        Analytics.setUserID(userId)
        print("🔍 Analytics: Set user ID: \(userId)")
    }
    
    func setUserProperty(_ value: String?, forName property: String) {
        Analytics.setUserProperty(value, forName: property)
        print("🔍 Analytics: Set user property \(property): \(value ?? "nil")")
    }
    
    // MARK: - App Lifecycle Events
    func trackAppLaunch() {
        Analytics.logEvent("app_launch", parameters: [
            "platform": "ios"
        ])
        print("🔍 Analytics: App launched")
    }
    
    func trackAppBackground() {
        Analytics.logEvent("app_background", parameters: nil)
        print("🔍 Analytics: App backgrounded")
    }
    
    func trackAppForeground() {
        Analytics.logEvent("app_foreground", parameters: nil)
        print("🔍 Analytics: App foregrounded")
    }
    
    // MARK: - Onboarding Events
    func trackOnboardingStart() {
        Analytics.logEvent("onboarding_start", parameters: nil)
        print("🔍 Analytics: Onboarding started")
    }
    
    func trackOnboardingStep(_ step: String, stepNumber: Int) {
        Analytics.logEvent("onboarding_step", parameters: [
            "step_name": step,
            "step_number": stepNumber
        ])
        print("🔍 Analytics: Onboarding step \(stepNumber): \(step)")
    }
    
    func trackOnboardingComplete() {
        Analytics.logEvent("onboarding_complete", parameters: nil)
        print("🔍 Analytics: Onboarding completed")
    }
    
    func trackOnboardingAbandoned(atStep step: String, stepNumber: Int) {
        Analytics.logEvent("onboarding_abandoned", parameters: [
            "step_name": step,
            "step_number": stepNumber
        ])
        print("🔍 Analytics: Onboarding abandoned at step \(stepNumber): \(step)")
    }
    
    // MARK: - Authentication Events
    func trackLoginAttempt(method: String) {
        Analytics.logEvent(AnalyticsEventLogin, parameters: [
            AnalyticsParameterMethod: method
        ])
        print("🔍 Analytics: Login attempt with method: \(method)")
    }
    
    func trackLoginSuccess(method: String) {
        Analytics.logEvent("login_success", parameters: [
            AnalyticsParameterMethod: method
        ])
        print("🔍 Analytics: Login successful with method: \(method)")
    }
    
    func trackLoginFailure(method: String, error: String? = nil) {
        var parameters: [String: Any] = [AnalyticsParameterMethod: method]
        if let error = error {
            parameters["error"] = error
        }
        Analytics.logEvent("login_failure", parameters: parameters)
        print("🔍 Analytics: Login failed with method: \(method), error: \(error ?? "unknown")")
    }
    
    func trackSignUpAttempt(method: String) {
        Analytics.logEvent(AnalyticsEventSignUp, parameters: [
            AnalyticsParameterMethod: method
        ])
        print("🔍 Analytics: Sign up attempt with method: \(method)")
    }
    
    func trackSignUpSuccess(method: String) {
        Analytics.logEvent("signup_success", parameters: [
            AnalyticsParameterMethod: method
        ])
        print("🔍 Analytics: Sign up successful with method: \(method)")
    }
    
    func trackLogout() {
        Analytics.logEvent("logout", parameters: nil)
        print("🔍 Analytics: User logged out")
    }
    
    // MARK: - Navigation Events
    func trackScreenView(_ screenName: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName
        ])
        print("🔍 Analytics: Screen view: \(screenName)")
    }
    
    func trackTabSwitch(from: String, to: String) {
        Analytics.logEvent("tab_switch", parameters: [
            "from_tab": from,
            "to_tab": to
        ])
        print("🔍 Analytics: Tab switch from \(from) to \(to)")
    }
    
    // MARK: - Timer Events
    func trackTimerStart(type: String, duration: TimeInterval, sessionType: String, roastLevel: String) {
        Analytics.logEvent("timer_start", parameters: [
            "timer_type": type,
            "duration_seconds": Int(duration),
            "session_type": sessionType,
            "roast_level": roastLevel
        ])
        print("🔍 Analytics: Timer started - type: \(type), duration: \(duration)s")
    }
    
    func trackTimerComplete(type: String, duration: TimeInterval, actualDuration: TimeInterval) {
        Analytics.logEvent("timer_complete", parameters: [
            "timer_type": type,
            "planned_duration_seconds": Int(duration),
            "actual_duration_seconds": Int(actualDuration),
            "completion_rate": actualDuration / duration
        ])
        print("🔍 Analytics: Timer completed - type: \(type), planned: \(duration)s, actual: \(actualDuration)s")
    }
    
    func trackTimerFailed(type: String, duration: TimeInterval, failedAfter: TimeInterval, reason: String) {
        Analytics.logEvent("timer_failed", parameters: [
            "timer_type": type,
            "planned_duration_seconds": Int(duration),
            "failed_after_seconds": Int(failedAfter),
            "failure_reason": reason,
            "completion_rate": failedAfter / duration
        ])
        print("🔍 Analytics: Timer failed - type: \(type), reason: \(reason), completed: \(failedAfter)s/\(duration)s")
    }
    
    func trackTimerPaused(type: String, timeElapsed: TimeInterval) {
        Analytics.logEvent("timer_paused", parameters: [
            "timer_type": type,
            "time_elapsed_seconds": Int(timeElapsed)
        ])
        print("🔍 Analytics: Timer paused - type: \(type), elapsed: \(timeElapsed)s")
    }
    
    func trackTimerResumed(type: String, timeElapsed: TimeInterval) {
        Analytics.logEvent("timer_resumed", parameters: [
            "timer_type": type,
            "time_elapsed_seconds": Int(timeElapsed)
        ])
        print("🔍 Analytics: Timer resumed - type: \(type), elapsed: \(timeElapsed)s")
    }
    
    // MARK: - Social Events
    func trackPostCreated(type: String) {
        Analytics.logEvent("post_created", parameters: [
            "post_type": type
        ])
        print("🔍 Analytics: Post created - type: \(type)")
    }
    
    func trackPostViewed(type: String) {
        Analytics.logEvent("post_viewed", parameters: [
            "post_type": type
        ])
        print("🔍 Analytics: Post viewed - type: \(type)")
    }
    
    func trackFriendRequestSent() {
        Analytics.logEvent("friend_request_sent", parameters: nil)
        print("🔍 Analytics: Friend request sent")
    }
    
    func trackFriendRequestAccepted() {
        Analytics.logEvent("friend_request_accepted", parameters: nil)
        print("🔍 Analytics: Friend request accepted")
    }
    
    func trackLeaderboardViewed(type: String) {
        Analytics.logEvent("leaderboard_viewed", parameters: [
            "leaderboard_type": type
        ])
        print("🔍 Analytics: Leaderboard viewed - type: \(type)")
    }
    
    // MARK: - Settings Events
    func trackSettingsChanged(setting: String, oldValue: String?, newValue: String) {
        Analytics.logEvent("settings_changed", parameters: [
            "setting_name": setting,
            "old_value": oldValue ?? "unknown",
            "new_value": newValue
        ])
        print("🔍 Analytics: Setting changed - \(setting): \(oldValue ?? "unknown") -> \(newValue)")
    }
    
    func trackRoastLevelChanged(from: String, to: String) {
        Analytics.logEvent("roast_level_changed", parameters: [
            "from_level": from,
            "to_level": to
        ])
        print("🔍 Analytics: Roast level changed from \(from) to \(to)")
    }
    
    func trackDifficultyChanged(from: String, to: String) {
        Analytics.logEvent("difficulty_changed", parameters: [
            "from_difficulty": from,
            "to_difficulty": to
        ])
        print("🔍 Analytics: Difficulty changed from \(from) to \(to)")
    }
    
    // MARK: - Feature Usage Events
    func trackFeatureUsed(_ featureName: String, parameters: [String: Any]? = nil) {
        var eventParameters = parameters ?? [:]
        eventParameters["feature_name"] = featureName
        
        Analytics.logEvent("feature_used", parameters: eventParameters)
        print("🔍 Analytics: Feature used: \(featureName)")
    }
    
    func trackTodoItemAdded() {
        Analytics.logEvent("todo_item_added", parameters: nil)
        print("🔍 Analytics: Todo item added")
    }
    
    func trackTodoItemCompleted() {
        Analytics.logEvent("todo_item_completed", parameters: nil)
        print("🔍 Analytics: Todo item completed")
    }
    
    func trackNotificationReceived(type: String) {
        Analytics.logEvent("notification_received", parameters: [
            "notification_type": type
        ])
        print("🔍 Analytics: Notification received - type: \(type)")
    }
    
    func trackNotificationTapped(type: String) {
        Analytics.logEvent("notification_tapped", parameters: [
            "notification_type": type
        ])
        print("🔍 Analytics: Notification tapped - type: \(type)")
    }
    
    // MARK: - Error Events
    func trackError(_ error: Error, context: String) {
        Analytics.logEvent("app_error", parameters: [
            "error_description": error.localizedDescription,
            "context": context
        ])
        print("🔍 Analytics: Error occurred in \(context): \(error.localizedDescription)")
    }
    
    // MARK: - Custom Events
    func trackCustomEvent(_ eventName: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(eventName, parameters: parameters)
        print("🔍 Analytics: Custom event: \(eventName)")
    }
} 
