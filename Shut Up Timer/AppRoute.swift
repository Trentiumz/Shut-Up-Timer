import SwiftUI;

enum AppRoute {
    case home
    case timer
    case timerCompleted(seconds: Int)
    case timerFailed(seconds: Int, roast: String? = nil)
    case login(onSuccess: () -> Void)
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
