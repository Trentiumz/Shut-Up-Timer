import SwiftUI
struct OnboardingView : View {
    enum OnboardingStage {
        case hello;
        case difficulty;
        case network;
        case loginQuery;
    }
    
    private var onDone: () -> Void;
    @State private var curStage: OnboardingStage;
    @EnvironmentObject var settings: Settings;
    @EnvironmentObject var credManager: CredManager;
    @EnvironmentObject var router: AppRouter;
    @Namespace private var transitionNS;
    private let rightwardAnimation = AnyTransition.asymmetric(
        insertion: AnyTransition.move(edge: .leading),
        removal: AnyTransition.move(edge: .trailing)
    )
    
    init(onDone: @escaping () -> Void) {
        self.onDone = onDone;
        self.curStage = .hello;
    }
    
    var body : some View {
        ZStack {
            switch curStage {
            case .hello:
                OnboardingHello(onPress: {
                    withAnimation {
                        self.curStage = .difficulty;
                    }
                })
                .transition(rightwardAnimation)
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
                        curStage = .network;
                    }
                })
                .transition(rightwardAnimation)
            case .network:
                NetworkScreen(onNext: { _ in
                    withAnimation {
                        curStage = .loginQuery;
                    }
                })
                .transition(rightwardAnimation)
            case .loginQuery:
                LoginQueryView(onNext: { selection in
                    withAnimation {
                        switch selection {
                        case .study:
                            onDone()
                        case .login:
                            router.toLogin(onSuccess: onDone)
                        }
                    }
                })
                .transition(rightwardAnimation)
            }
        }
        .animation(.easeInOut, value: curStage);
    }
}

#Preview {
    OnboardingView(onDone: {})
        .environmentObject(SettingsLoader.loadSettings())
        .environmentObject(CredManager())
        .environmentObject(AppRouter())
}
