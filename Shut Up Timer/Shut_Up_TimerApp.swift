//
//  Shut_Up_TimerApp.swift
//  Shut Up Timer
//
//  Created by user279207 on 4/20/25.
//

import SwiftUI
import UIKit
import Supabase

@main
struct Shut_Up_TimerApp: App {
    // register app delegate for push notifications
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var notificationManager = NotificationManager()
    
    var router: AppRouter = AppRouter();
    var settings: Settings = SettingsLoader.loadSettings(onUpdate: { newSettings in
                    SettingsLoader.saveSettings(newSettings);
    });
    var sessions: Sessions = SessionsLoader.loadSessions(onUpdate: {_ in });
    var todoList: ToDoListV2 = ToDoLoader.getToDo();
    var credManager: CredManager = CredManager();
    // TODO: onReceive is called BEFORE the object is changed, so the updates aren't actually saved !
    
    var curUser: CurUser
    
    init() {
        let credManager = self.credManager;
        let todoList = self.todoList;
        sessions.onUpdate = { newSessions in
            SessionsLoader.saveSessions(newSessions);
            // TODO: Update when user logs in - right now it won't update so...
            if credManager.loggedIn {
                Task {
                    try await credManager.supabaseClient.rpc("change_iq", params: ["new_iq": newSessions.getIQ()]).execute();
                    try await credManager.supabaseClient.rpc("change_hours", params: ["new_hours": toISO(TimeInterval(newSessions.getTotalTimeLocked()))]).execute();
                    try await credManager.supabaseClient.rpc("change_top_categories", params: ["new_top_categories": newSessions.getTopCategoryStrings(toDoList: todoList)]).execute();
                    try await credManager.supabaseClient.rpc("change_roasts", params: ["new_roasts": newSessions.getLatestRoasts()]).execute();
                }
            }
        }
        self.curUser = CurUser(credManager: CredManager())
        watchTodo();
    }
    
    @MainActor
    func watchTodo() {
        withObservationTracking {
            _ = todoList.activeLst
            _ = todoList.inactiveLst
        } onChange: {
            Task {
                await MainActor.run {
                    ToDoLoader.saveToDo(todo: todoList)
                }
            }
            Task { await watchTodo() }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(router)
                .environmentObject(settings)
                .environmentObject(sessions)
                .environmentObject(credManager)
                .environmentObject(notificationManager)
                .environment(curUser)
                .environment(todoList)
                .preferredColorScheme(.light)
        }
    }
}
