import SwiftUI;

// Main model for app routing - also keeps track of models for all states
class AppRouter: ObservableObject {
    @Published var path = NavigationPath();
    @Published var timerViewModel: TimerViewModel = TimerViewModel();
    
    func toTimerState(params: TimerParam, todoID: UUID, startTime: Date = Date()) {
        switch params {
        case .countdown(let seconds):
            timerViewModel.reset(totTime: seconds, startTime: startTime, todoID: todoID);
        }
        path.append(PathElement(route: AppRoute.timer));
    }

    func toLogin(onSuccess: @escaping () -> Void) {
        path.append(PathElement(route: AppRoute.login(onSuccess: onSuccess)))
    }
    
    func toTimerCompleted(totTime: Int) {
        assert(!timerViewModel.isRunning);
        path.append(PathElement(route: AppRoute.timerCompleted(seconds: totTime)))
    }
    
    func toTimerFailed(totTime: Int) {
        assert(!timerViewModel.isRunning);
        path.append(PathElement(route: AppRoute.timerFailed(seconds: totTime)))
    }
    
    func toHome() {
        while !path.isEmpty {
            path.removeLast();
        }
    }
}
