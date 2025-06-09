import SwiftUI;

// Main model for app routing - also keeps track of models for all states
class AppRouter: ObservableObject {
    @Published var path = NavigationPath();
    
    func toTimerState(params: TimerParam, todoID: UUID, startTime: Date = Date()) {
        path.append(PathElement(route: AppRoute.timer(timerModel: TimerViewModel(startParams: params, startTodo: todoID, startPhase: .active))));
    }
    func toTimerState(sessionInProgress: SessionInProgress) {
        path.append(PathElement(route: AppRoute.timer(timerModel: TimerViewModel(from: sessionInProgress, startPhase: .active))))
    }

    func toLogin(onSuccess: @escaping () -> Void) {
        path.append(PathElement(route: AppRoute.login(onSuccess: onSuccess)))
    }
    
    func toTimerCompleted(timerModel: TimerViewModel) {
        assert(timerModel.curSession.status == .succeeded) // ensure we actually completed!
        let totTime = switch(timerModel.curSession.initialParam) {
        case .countdown(let seconds):
            seconds
        }
        path.append(PathElement(route: AppRoute.timerCompleted(seconds: totTime)))
    }
    
    func toTimerFailed(timerModel: TimerViewModel, roast: String? = nil) {
        assert(timerModel.curSession.status == .failed) // ensure we actually failed
        let totTime = switch(timerModel.curSession.initialParam) {
        case .countdown(let seconds):
            seconds
        }
        path.append(PathElement(route: AppRoute.timerFailed(seconds: totTime, roast: roast)))
    }

    func toInviteFriends() {
        path.append(PathElement(route: AppRoute.inviteFriends));
    }
    
    func toHome() {
        while !path.isEmpty {
            path.removeLast();
        }
    }
}
