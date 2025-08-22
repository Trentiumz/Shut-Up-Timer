import SwiftUI;

enum AppRoute {
    case home
    case noLeaveTimer(timerModel: TimerViewModel<NoLeaveSessionManager>)
    case appBlockTimer(timerModel: TimerViewModel<AppBlockSessionManager>)
    case timerCompleted(session: TempSession)
    case timerFailed(session: TempSession)
    case timerFailedCamera(sessionID: UUID)
    case login(onSuccess: () -> Void)
    case inviteFriends
    case viewRequests
    case albumView
    case achievementsView
    case feedbackView
    case notifications
}

struct PathElement : Hashable {
    var id = UUID();
    var route: AppRoute;
    
    static func == (lhs: PathElement, rhs: PathElement) -> Bool {
        return lhs.id == rhs.id;
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
