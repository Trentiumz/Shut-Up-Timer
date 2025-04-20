//
//  ContentView.swift
//  Shut Up Timer
//
//  Created by user279207 on 4/20/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppStateModel;
    
    init() {
    }
    
    var body: some View {
        switch appState.state {
        case .home:
            HomeView()
        case .timer:
            TimerView()
        case .timerCompleted(let seconds):
            TimerCompletedView(timeLocked: seconds)
        }
    }
}

#Preview {
    ContentView().environmentObject(AppStateModel(curState: .home))
}
