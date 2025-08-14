import Foundation
import ActivityKit
import UserNotifications
struct SilentPushHandler {
    static func handleLiveActivityNotification() {
        print("Handling live activity notification")
        
        // Generate roast features
        let persistenceController = PersistenceController.shared
        let viewContext = persistenceController.container.viewContext
        
        // Send request to backend
        Task {
            // Initialize CredManager and FastAPI
            let subscriptionManager = await SubscriptionManager()
            let credManager = CredManager(subscriptionManager: subscriptionManager)
            let roastResult = await RoastGenerator.generateLiveActivityRoast(viewContext: viewContext, credManager: credManager)
            
            if let roastResult = roastResult {
                switch(LiveActivitySessionWrapper.shared.currentSession) {
                case .countdown(let startTime, let duration, _):
                    if startTime <= Date() && Date() <= startTime.addingTimeInterval(duration) {
                        Task {
                            var foundActivity = false
                            for activity in Activity<Procrastination_Countdown_ActivityAttributes>.activities {
                                let content = Procrastination_Countdown_ActivityAttributes.ContentState(curRoast: roastResult, duration: activity.content.state.duration)
                                await activity.update(ActivityContent(state: content, staleDate: nil))
                                if !foundActivity {
                                    _ = await credManager.fastAPI.scheduleLiveActivityNotification(timestamp: Date().addingTimeInterval(30 * 60))
                                    foundActivity = true
                                }
                            }
                        }
                    }
                default:
                    print("No live activity detected")
                }
            } else {
                print("Roast Result was nil for live activity")
            }
        }
    }
    
    static func handleIntervalNotificationBeckon() {
        print("Handling interval notification beckon")
        let settings = SettingsLoader.loadSettings()
        guard settings.dailyBeckon else {
            print("User turned off daily beckon notification")
            return
        }
        
        // Send request to backend
        Task {
            // Generate roast features
            let persistenceController = PersistenceController.shared
            let viewContext = persistenceController.container.viewContext
            let featureGenerator = await RoastGenerator.RoastFeatureGenerator(viewContext: viewContext)
            let roastFeatures = await featureGenerator.generateFeatures()
            
            do {
                // Initialize CredManager and FastAPI
                let subscriptionManager = await SubscriptionManager()
                await subscriptionManager.loadProducts()
                await subscriptionManager.updateSubscriptionStatus()
                print("Silent Push Beckon Generator subscription id: \(String(describing: await subscriptionManager.originalTransactionId))")
                if await subscriptionManager.currentSubscription == nil {
                    print("No subscription, will not generate beckon message")
                    return
                }
                let credManager = CredManager(subscriptionManager: subscriptionManager)
                let beckonResult = try await credManager.fastAPI.generateBeckonMessages(roastFeatures: roastFeatures)
                
                if let result = beckonResult {
                    let center = UNUserNotificationCenter.current()
                    let currentTime = Date()
                    
                    for (index, message) in result.messages.enumerated() {
                        let content = UNMutableNotificationContent()
                        content.title = result.title
                        content.body = message
                        content.sound = .default
                        
                        // Set trigger time
                        let triggerDate = Calendar.current.dateComponents(
                            [.year, .month, .day, .hour, .minute, .second],
                            from: currentTime.addingTimeInterval(TimeInterval(1 + index))
                        )
                        
                        let trigger = UNCalendarNotificationTrigger(
                            dateMatching: triggerDate,
                            repeats: false
                        )
                        
                        let request = UNNotificationRequest(
                            identifier: UUID().uuidString,
                            content: content,
                            trigger: trigger
                        )
                        
                        try await center.add(request)
                        print("Successfully added messages: \(result.messages), '\(result.title)'")
                    }
                }
            } catch {
                print("Error generating beckon messages: \(error)")
            }
        }
    }
    
    private static func scheduleBeckonNotification(message: String, title: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "beckon-\(UUID().uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling beckon notification: \(error)")
            }
        }
    }
}
