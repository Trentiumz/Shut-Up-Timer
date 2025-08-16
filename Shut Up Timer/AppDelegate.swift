import UIKit
import Combine
import FirebaseCore

class AppDelegate: UIResponder, UIApplicationDelegate {
    let notificationManager = NotificationManager()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        notificationManager.registerForPushNotifications(application: application)
        FirebaseApp.configure()
        
        // Track app launch
        AnalyticsManager.shared.trackAppLaunch()
        
        return true
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        notificationManager.didRegisterForRemoteNotifications(deviceToken: deviceToken)
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        notificationManager.didFailToRegisterForRemoteNotifications(error: error)
    }

    // For SceneDelegate apps
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Received silent push with userInfo: \(userInfo)")
        
        if let flag = userInfo["flag"] as? String {
            if flag == "send-interval-notification-beckon" {
                SilentPushHandler.handleIntervalNotificationBeckon()
            } else if flag == "live_activity_notif" {
                SilentPushHandler.handleLiveActivityNotification()
            }
        }
        
        // Fetch data or schedule local notifications here
        
        completionHandler(.newData)
    }

}
