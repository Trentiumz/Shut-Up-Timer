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

@main
struct Shut_Up_TimerApp: App {
    // register app delegate for push notifications
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let notificationManager = NotificationManager()
    let router = AppRouter()
    let settings = SettingsLoader.loadSettings()
    let sessions = SessionsLoader.loadSessions()
    let todoList = ToDoLoader.getToDo()
    let credManager = CredManager()
    let postLoader = PostLoader.loadPostLoader()
    let curUser: CurUser
    
    init() {
        // Create curUser with the same credManager instance
        self.curUser = CurUser(credManager: credManager)
        
        // Set up subscriptions
        setupSubscriptions(sessions: sessions, credManager: credManager, todoList: todoList, settings: settings)
    }
    
    private func setupSubscriptions(sessions: Sessions, credManager: CredManager, todoList: ToDoListV2, settings: Settings) {
        // Subscribe to sessions changes
        sessions.didChange
            .sink { updatedSessions in
                SessionsLoader.saveSessions(updatedSessions)
                // Update backend when user is logged in
                if credManager.loggedIn {
                    Task {
                        try await credManager.supabaseClient.rpc("change_iq", params: ["new_iq": updatedSessions.getIQ()]).execute()
                        try await credManager.supabaseClient.rpc("change_hours", params: ["new_hours": toISO(TimeInterval(updatedSessions.getTotalTimeLocked()))]).execute()
                        try await credManager.supabaseClient.rpc("change_top_categories", params: ["new_top_categories": updatedSessions.getTopCategoryStrings(toDoList: todoList)]).execute()
                        try await credManager.supabaseClient.rpc("change_roasts", params: ["new_roasts": updatedSessions.getLatestRoasts()]).execute()
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
        
        // Subscribe to todo list changes
        todoList.didChange
            .sink { updatedTodoList in
                ToDoLoader.saveToDo(todo: updatedTodoList)
            }
            .store(in: &todoList.cancellables)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(router)
                .environmentObject(settings)
                .environmentObject(sessions)
                .environmentObject(credManager)
                .environmentObject(notificationManager)
                .environmentObject(curUser)
                .environmentObject(todoList)
                .environmentObject(postLoader)
                .preferredColorScheme(.light)
        }
    }
}
