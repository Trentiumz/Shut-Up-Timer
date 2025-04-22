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
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(router);
        }
    }
}
