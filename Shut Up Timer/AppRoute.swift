import SwiftUI;

enum AppRoute {
    case home
    case timer(timerModel: TimerViewModel)
    case timerCompleted(session: SessionEntry)
    case timerFailed(seconds: TimeInterval, roast: String? = nil)
    case login(onSuccess: () -> Void)
    case inviteFriends
    case viewRequests
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
