//
//  Shut_Up_TimerApp.swift
//  Shut Up Timer
//
//  Created by user279207 on 4/20/25.
//

import SwiftUI
import UIKit
import Supabase
import Combine
import FamilyControls

@main
struct Shut_Up_TimerApp: App {
    // register app delegate for push notifications
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared
    
    let router = AppRouter()
    let settings = SettingsLoader.loadSettings()
    let subscriptionManager = SubscriptionManager()
    let credManager: CredManager
    let sessions = SessionLoader() // New Core Data wrapper
    let curUser: CurUser
    let roastInformation = RoastInformation.loadRoastInformation()
    
    let liveActivityManager: LiveActivityManager
    
    init() {
        // Create credManager with subscriptionManager
        self.credManager = CredManager(subscriptionManager: subscriptionManager)
        // Create curUser with the same credManager instance
        self.curUser = CurUser(credManager: credManager)
        self.liveActivityManager = LiveActivityManager(fastAPIClient: credManager.fastAPI)
        
        requestFamilyPermissions()
        // Set up subscriptions
        setupSubscriptions(credManager: credManager, settings: settings)
    }
    
    private func requestFamilyPermissions() {
        // Request FamilyControls authorization
        Task {
            do {
                try await FamilyControls.AuthorizationCenter.shared.requestAuthorization(for: .individual)
                
            } catch {
                print("Authorization failed for family controls: \(error)")
            }
        }
    }
    
    private func setupSubscriptions(credManager: CredManager, settings: Settings) {
        // Subscribe to sessions changes
        sessions.didChange
            .sink { _ in
                // Update backend when user is logged in
                if credManager.loggedIn {
                    Task {
                        let context = persistenceController.container.viewContext
                        try await credManager.supabaseClient.rpc("change_iq", params: ["new_iq": Session.getTotalIQ(context: context)]).execute()
                        try await credManager.supabaseClient.rpc("change_hours", params: ["new_hours": toISO(TimeInterval(Session.getTotalTimeLocked(context: context)))]).execute()
                        try await credManager.supabaseClient.rpc("change_top_categories", params: ["new_top_categories": Session.getTopCategoryStrings(context: context)]).execute()
                        try await credManager.supabaseClient.rpc("change_roasts", params: ["new_roasts": Session.getLatestRoasts(context: context)]).execute()
                    }
                }
            }
            .store(in: &sessions.cancellables)
        
        // Subscribe to settings changes
        settings.didChange
            .sink { updatedSettings in
                SettingsLoader.saveSettings(updatedSettings)
            }
            .store(in: &settings.cancellables)
        
        roastInformation.didChange
            .sink { updatedRoastInformation in
                updatedRoastInformation.saveRoastInformation()
            }
            .store(in: &roastInformation.cancellables)
        
        subscriptionManager.transactionIdUpdate
            .sink { id in
                Task {
                    do {
                        let success = try await credManager.fastAPI.linkSubscription()
                        print("Linking subscription result: \(success)")
                    } catch {
                        print("Failed to link subscription: \(error)")
                    }
                }
            }
            .store(in: &subscriptionManager.cancellables)
        
        appDelegate.notificationManager.remoteNotificationGranted
            .sink {
                credManager.sendTokenToBackend()
            }
            .store(in: &appDelegate.notificationManager.cancellables)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(router)
                .environmentObject(settings)
                .environmentObject(sessions)
                .environmentObject(credManager)
                .environmentObject(appDelegate.notificationManager)
                .environmentObject(curUser)
                .environmentObject(subscriptionManager)
                .environmentObject(roastInformation)
                .environmentObject(liveActivityManager)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(.light)
        }
    }
}
