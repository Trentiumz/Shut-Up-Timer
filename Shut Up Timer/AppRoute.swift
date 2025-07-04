import SwiftUI;

enum AppRoute {
    case home
    case timer(timerModel: TimerViewModel)
    case timerCompleted(session: SessionEntry)
    case timerFailed(session: SessionEntry)
    case timerFailedCamera(sessionID: UUID)
    case login(onSuccess: () -> Void)
    case inviteFriends
    case viewRequests
    case albumView(month: Int, year: Int)
    case feedbackView
    case notifications
    case addPost
    case postView(month: Int, year: Int)
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
