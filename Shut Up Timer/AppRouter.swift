import SwiftUI;

// Main model for app routing - also keeps track of models for all states
class AppRouter: ObservableObject {
    @Published var path = NavigationPath();
    
    func toTimerState(type: TimerType, todoID: UUID, managerType: TimerManagerType, liveActivityManager: LiveActivityManager, startTime: Date = Date()) {
        liveActivityManager.userStartedStudying()
        let params = TimerParam.from(type)
        switch managerType {
        case .noLeave:
            let manager = NoLeaveSessionManager(initialParam: params, startTime: Date(), curParam: params, tasks: [], lastActiveUpdate: Date(), lastUpdate: Date(), curTodo: todoID, status: .paused)
            path.append(PathElement(route: AppRoute.noLeaveTimer(timerModel: TimerViewModel<NoLeaveSessionManager>(from: manager, startPhase: .active, appReopened: false))));
        case .appBlock:
            let manager = AppBlockSessionManager(initialParam: params, startTime: Date(), curParam: params, tasks: [], lastUpdate: Date(), curTodo: todoID, status: .paused)
            path.append(PathElement(route: AppRoute.appBlockTimer(timerModel: TimerViewModel<AppBlockSessionManager>(from: manager, startPhase: .active, appReopened: false))));
        }
    }
    func toTimerState(sessionInProgress: CurSessionManagerType, liveActivityManager: LiveActivityManager, appReopened: Bool = true) {
        liveActivityManager.userStartedStudying()
        switch sessionInProgress {
        case .noLeaveSessionManager(let manager):
            path.append(PathElement(route: AppRoute.noLeaveTimer(timerModel: TimerViewModel<NoLeaveSessionManager>(from: manager, startPhase: .active, appReopened: appReopened))))
        case .appBlockSessionManager(let manager):
            path.append(PathElement(route: AppRoute.appBlockTimer(timerModel: TimerViewModel<AppBlockSessionManager>(from: manager, startPhase: .active, appReopened: appReopened))))
        }
    }

    func toLogin(onSuccess: @escaping () -> Void) {
        path.append(PathElement(route: AppRoute.login(onSuccess: onSuccess)))
    }
    
    func toTimerCompleted(curSession: TempSession) {
        assert(curSession.success) // ensure we actually completed!
        path.append(PathElement(route: AppRoute.timerCompleted(session: curSession)))
    }
    
    func toTimerFailed(session: TempSession) {
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
    
    func toAlbumView() {
        path.append(PathElement(route: AppRoute.albumView))
    }
    
    func toAchievementsView() {
        path.append(PathElement(route: AppRoute.achievementsView))
    }
    
    func toFeedbackView() {
        path.append(PathElement(route: AppRoute.feedbackView))
    }
    
    func toNotifications() {
        path.append(PathElement(route: AppRoute.notifications))
    }
    
    func toAddPost() {
        path.append(PathElement(route: AppRoute.addPost))
    }
    
    func toPostView(month: Int, year: Int) {
        path.append(PathElement(route: AppRoute.postView(month: month, year: year)))
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast();
        }
    }
    
    func toHome() {
        while !path.isEmpty {
            path.removeLast();
        }
    }
}
