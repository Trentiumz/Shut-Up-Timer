import Foundation
import Combine
import UIKit
import UserNotifications

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var notifications: [ClientNotification] = []
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        notifications = ClientNotificationLoader.loadNotifications()
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.refresh()
        }
    }
    
    func registerForPushNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Push permission not granted: \(String(describing: error))")
            }
        }
    }

    func didRegisterForRemoteNotifications(deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        UserDefaults.standard.set(token, forKey: "device-token-push")
    }

    func didFailToRegisterForRemoteNotifications(error: Error) {
        print("Failed to register for push notifications: \(error)")
    }

    // Handle push notification while app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        self.refresh()
        completionHandler([.banner, .sound])
    }

    // Handle tap on notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification tapped with payload: \(response.notification.request.content.userInfo)")
        self.refresh()
        completionHandler()
    }
    
    func refresh() {
        self.notifications = ClientNotificationLoader.loadNotifications()
    }
    
    func clearNotifications() {
        ClientNotificationLoader.saveNotifications([])
        self.refresh();
    }
}
