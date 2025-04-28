import SwiftUI
struct OnboardingView : View {
    enum OnboardingStage {
        case difficulty;
        case loginQuery;
    }
    
    private var onDone: () -> Void;
    @State private var curStage: OnboardingStage;
    @EnvironmentObject var settings: Settings;
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
                    settings.difficulty = difficulty;
                    if(difficulty == .easy) {
                        settings.roastLevel = .low;
                    } else if(difficulty == .medium) {
                        settings.roastLevel = .med;
                    } else if(difficulty == .asian) {
                        settings.roastLevel = .high;
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
