import SwiftUI
struct OnboardingView : View {
    enum OnboardingStage {
        case difficulty;
        case loginQuery;
    }
    
    private var onDone: () -> Void;
    @State private var curStage: OnboardingStage;
    @Namespace private var transitionNS;
    
    init(onDone: @escaping () -> Void) {
        self.onDone = onDone;
        self.curStage = .difficulty;
    }
    
    var body : some View {
        ZStack {
            switch curStage {
            case .difficulty:
                DifficultyScreen(onNext: { difficulty in
                    Settings.setDifficulty(val: difficulty)
                    if(difficulty == .easy) {
                        Settings.setRoastLevel(val: .low);
                    } else if(difficulty == .medium) {
                        Settings.setRoastLevel(val: .med);
                    } else if(difficulty == .asian) {
                        Settings.setRoastLevel(val: .high);
                    }
                    withAnimation {
                        curStage = .loginQuery;
                    }
                })
                .transition(.move(edge: .trailing))
            case .loginQuery:
                LoginQueryView(onNext: { selection in
                    withAnimation {
                        onDone()
                    }
                })
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut, value: curStage);
    }
}
