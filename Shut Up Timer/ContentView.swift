//
//  ContentView.swift
//  Shut Up Timer
//
//  Created by user279207 on 4/20/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var router: AppRouter = AppRouter();
    
    init() {
    }
    
    var body: some View {
        NavigationStack(path:$router.path){
            HomeView()
                .environmentObject(router)
                .navigationDestination(for: AppRoute.self) { value in
                    switch value {
                    case .timer:
                        TimerView(timerViewModel: router.timerViewModel).environmentObject(router)
                    case .timerCompleted(let seconds):
                        TimerCompletedView(timeLocked: seconds).environmentObject(router)
                    default:
                        Text("Invalid")
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
