import SwiftUI

class AppViewModel: ObservableObject {
    @Published var state: AppState = .home

    func goToTimer() {
        state = .timer
    }

    func goToHome() {
        state = .home
    }
}
