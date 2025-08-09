import Foundation
import UserNotifications
struct SilentPushHandler {
    static func handleIntervalNotificationBeckon() {
        print("Handling interval notification beckon")
        
        // Generate roast features
        let persistenceController = PersistenceController.shared
        let viewContext = persistenceController.container.viewContext
        let featureGenerator = RoastGenerator.RoastFeatureGenerator(viewContext: viewContext)
        let roastFeatures = featureGenerator.generateFeatures()
        
        // Send request to backend
        Task {
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
