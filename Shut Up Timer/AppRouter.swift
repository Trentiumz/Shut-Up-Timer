import SwiftUI;

class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var timerViewModel: TimerViewModel = TimerViewModel();
    @Published var timerCompletedViewModel: TimerCompletedViewModel = TimerCompletedViewModel();
    
    func toTimerState(totTime: Int){
        timerViewModel.reset(totTime: totTime);
        path.append("timer");
    }
    
    func toTimerCompleted(totTime: Int) {
        timerCompletedViewModel.reset(totTime: totTime);
        path.append("completed-timer")
    }
    
    func toHome() {
        while path.count > 1 {
            path.removeLast();
        }
    }
}
