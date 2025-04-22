import SwiftUI;

// Main model for app routing - also keeps track of models for all states
class AppRouter: ObservableObject {
    @Published var path = NavigationPath();
    @Published var timerViewModel: TimerViewModel = TimerViewModel();
    
    func toTimerState(totTime: Int){
        timerViewModel.reset(totTime: totTime);
        path.append(AppRoute.timer);
    }
    
    func toTimerCompleted(totTime: Int) {
        assert(!timerViewModel.isRunning);
        path.append(AppRoute.timerCompleted(seconds: totTime))
    }
    
    func toTimerFailed(totTime: Int) {
        assert(!timerViewModel.isRunning);
        path.append(AppRoute.timerFailed(seconds: totTime))
    }
    
    func toHome() {
        while !path.isEmpty {
            path.removeLast();
        }
    }
}
