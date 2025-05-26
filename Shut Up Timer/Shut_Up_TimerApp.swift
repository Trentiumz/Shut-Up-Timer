//
//  Shut_Up_TimerApp.swift
//  Shut Up Timer
//
//  Created by user279207 on 4/20/25.
//

import SwiftUI
import UIKit

@main
struct Shut_Up_TimerApp: App {
    @StateObject var router: AppRouter = AppRouter();
    @StateObject var settings: Settings = SettingsLoader.loadSettings();
    @StateObject var sessions: Sessions = SessionsLoader.loadSettings();
    @StateObject var todoList: ToDoList = ToDoLoader.getToDo();
    @StateObject var credManager: CredManager = CredManager();
    // TODO: onReceive is called BEFORE the object is changed, so the updates aren't actually saved !
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(router)
                .environmentObject(settings)
                .environmentObject(sessions)
                .environmentObject(todoList)
                .environmentObject(credManager)
                .onReceive(settings.objectWillChange) { newSettings in
                    SettingsLoader.saveSettings(newSettings);
                }
                .onReceive(sessions.objectWillChange) { newSessions in
                    SessionsLoader.saveSettings(newSessions);
                    // TODO: Update when user logs in - right now it won't update so...
                    if credManager.loggedIn {
                        Task {
                            try await credManager.supabaseClient.rpc("change_iq", params: ["new_iq": newSessions.getIQ()]).execute();
                            try await credManager.supabaseClient.rpc("change_hours", params: ["new_hours": toISO(TimeInterval(newSessions.getTotalTimeLocked()))]).execute();
                            try await credManager.supabaseClient.rpc("change_roasts", params: ["new_roasts": newSessions.getRoasts()]).execute();
                            try await credManager.supabaseClient.rpc("change_top_categories", params: ["new_top_categories": newSessions.getTopCategoryStrings(toDoList: todoList)]).execute();
                        }
                    }
                }
                .onReceive(todoList.objectWillChange) { newToDoList in
                    // Save the todo list whenever it changes
                    ToDoLoader.saveToDo(todo: newToDoList);
                }
        }
    }
}
