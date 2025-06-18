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
    
    func toTimerCompleted(curSession: SessionEntry) {
        assert(curSession.success) // ensure we actually completed!
        path.append(PathElement(route: AppRoute.timerCompleted(session: curSession)))
    }
    
    func toTimerFailed(session: SessionEntry) {
        assert(!session.success) // ensure we actually failed
        path.append(PathElement(route: AppRoute.timerFailed(session: session)))
    }
    
    func toTimerCameraView(sessionID: UUID) {
        path.append(PathElement(route: AppRoute.timerFailedCamera(sessionID: sessionID)))
    }

    func toInviteFriends() {
        path.append(PathElement(route: AppRoute.inviteFriends));
    }
    
    func toViewRequests() {
        path.append(PathElement(route: AppRoute.viewRequests))
    }
    
    func toAlbumView(month: Int, year: Int) {
        path.append(PathElement(route: AppRoute.albumView(month: month, year: year)))
    }
    
    func toHome() {
        while !path.isEmpty {
            path.removeLast();
        }
    }
}
