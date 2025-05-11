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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(router)
                .environmentObject(settings)
                .environmentObject(sessions)
                .environmentObject(todoList)
                .environmentObject(credManager)
                .onReceive(settings.objectWillChange) { _ in
                    SettingsLoader.saveSettings(settings);
                }
                .onReceive(sessions.objectWillChange) { _ in
                    SessionsLoader.saveSettings(sessions);
                    // TODO: Update when user logs in - right now it won't update so...
                    if credManager.loggedIn {
                        Task {
                            try await credManager.supabaseClient.rpc("change_iq", params: ["new_iq": sessions.getIQ()]).execute();
                        }
                    }
                }
                .onReceive(todoList.objectWillChange) { _ in
                    ToDoLoader.saveToDo(todo: todoList)
                }
        }
    }
}
