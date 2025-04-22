//
//  Shut_Up_TimerApp.swift
//  Shut Up Timer
//
//  Created by user279207 on 4/20/25.
//

import SwiftUI

@main
struct Shut_Up_TimerApp: App {
    var router: AppRouter = AppRouter();
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(router);
        }
    }
}
