//
//  NotificationService.swift
//  Notification Remote Receival
//
//  Created by Daniel Ye on 2025-06-29.
//

import UserNotifications
import Foundation

class NotificationService: UNNotificationServiceExtension {
    private let suiteName = "group.io.notifications.io.kd.shutuptimer.shared"
    private let notificationsKey = "client-notifications"
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        print("I did receive!")
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            let _ = bestAttemptContent.userInfo
            
            // Check for interval notification beckon
            processMutableNotificaiton(content: bestAttemptContent)
            
            contentHandler(bestAttemptContent)
        }
    }
    
    private func processMutableNotificaiton(content: UNMutableNotificationContent) {
        print("Processing notification \(content)")
        let userInfo = content.userInfo
        
        // Extract custom_data
        guard let customData = userInfo["custom_data"] as? [String: Any],
              let type = customData["type"] as? String else {
            print("No custom_data or type found in notification")
            return
        }
        
        // Create notification using direct constructors
        var notification: ClientNotification? = nil
        print("Notifcation's type is \(type)")
        print("The notification is \(customData)")
        switch type {
        case "friend_request":
            if let id = customData["id"] as? String,
               let senderId = customData["sender_id"] as? String,
               let pfp = customData["pfp"] as? String,
               let username = customData["username"] as? String,
               let createdAtStr = customData["created_at"] as? String,
               let createdAt = parseISO8601Date(createdAtStr) {
                notification = .friendReq(id: id, sender_id: senderId, pfp: pfp, username: username, created_at: createdAt)
                content.title = "New Friend Request"
                content.body = "\(username) wants to be your friend"
            }
        case "devResponse":
            if let response = customData["response"] as? String {
                print("The dev response is \(response)")
                notification = .devResponse(response: response)
                content.title = "Developer Response"
                content.body = response
            }
        default:
            print("Unknown notification type: \(type)")
            return
        }
        
        print("Saving notification \(notification ?? .devResponse(response: "no notification data (this means notification is nil but idk how to display that)"))")
        if let notification = notification {
            saveNotificationToUserDefaults(notification)
        }
    }
    
    private func saveNotificationToUserDefaults(_ notification: ClientNotification) {
        var notifications = ClientNotificationLoader.loadNotifications()
        print("Current notifications are \(notifications)")
        notifications.append(notification)
        print("Saving notifications \(notifications)")
        ClientNotificationLoader.saveNotifications(notifications)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    

    
}
