import SwiftUI

class AppStateModel: ObservableObject {
    @Published var state: AppState
    
    init(curState: AppState) {
        self.state = curState
    }

    func changeState(state: AppState) {
        self.state = state;
    }
}
