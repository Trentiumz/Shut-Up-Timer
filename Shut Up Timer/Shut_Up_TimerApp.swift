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
    @StateObject var router: AppRouter = AppRouter();
    @StateObject var settings: Settings = SettingsLoader.loadSettings();
    @StateObject var sessions: Sessions = SessionsLoader.loadSettings();
    @State private var session: Session? = try? SupabaseClient.shared.auth.session
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(router)
                .environmentObject(settings)
                .environmentObject(sessions)
                .onReceive(settings.objectWillChange) { _ in
                    SettingsLoader.saveSettings(settings);
                }
                .onReceive(sessions.objectWillChange) { _ in
                    SessionsLoader.saveSettings(sessions);
                };
        }
    }
}
