import SwiftUI;

class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var timerViewModel: TimerViewModel? = nil;
    
    func toTimerState(totTime: Int){
        timerViewModel?.destroy();
        timerViewModel = TimerViewModel(totTime: totTime);
        path.append("timer");
    }
}
