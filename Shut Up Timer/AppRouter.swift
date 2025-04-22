import SwiftUI;

// Main model for app routing - also keeps track of models for state transitions
class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var timerViewModel: TimerViewModel = TimerViewModel();
    
    func toTimerState(totTime: Int){
        timerViewModel.reset(totTime: totTime);
        path.append(AppRoute.timer);
    }
    
    func toTimerCompleted(totTime: Int) {
        path.append(AppRoute.timerCompleted(seconds: totTime))
    }
    
    func toHome() {
        while !path.isEmpty {
            path.removeLast();
        }
    }
}
