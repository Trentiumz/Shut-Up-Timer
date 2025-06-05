import SwiftUI
struct OnboardingView : View {
    enum OnboardingStage {
        case hello;
        case answerForMe;
        case difficulty;
        case network;
        case loginQuery;
    }
    
    private var onDone: () -> Void;
    @State private var curStage: OnboardingStage;
    @EnvironmentObject var settings: Settings;
    @EnvironmentObject var router: AppRouter;
    @Namespace private var transitionNS;
    // temporary variable to keep track of whether the next transition should be rightward or left
    @State private var transitionRight = true;
    
    private let leftwardAnimation = AnyTransition.asymmetric(
        insertion: AnyTransition.move(edge: .trailing),
        removal: AnyTransition.move(edge: .leading)
    )
    private let rightwardAnimation = AnyTransition.asymmetric(
        insertion: AnyTransition.move(edge: .leading),
        removal: AnyTransition.move(edge: .trailing)
    )
    private func getCurTransition() -> AnyTransition {
        if transitionRight {
            return rightwardAnimation;
        } else {
            return leftwardAnimation;
        }
    }
    
    init(onDone: @escaping () -> Void) {
        self.onDone = onDone;
        self.curStage = .hello;
    }
    
    var body : some View {
        ZStack {
            switch curStage {
            case .hello:
                OnboardingHello(
                    infoText: "Welcome to your Asian parent-approved focus companion",
                    buttonText: "Hello?",
                    onPress: {
                        transitionRight = true;
                        withAnimation {
                            self.curStage = .answerForMe;
                        }
                    },
                    onPrevious: nil)
                .transition(getCurTransition())
            case .answerForMe:
                OnboardingHello(
                    infoText: "Answer 5 questions for me lah",
                    buttonText: "Yes Mother!",
                    onPress: {
                        transitionRight = true;
                        withAnimation {
                            self.curStage = .difficulty
                        }
                    },
                    onPrevious: {
                        transitionRight = false;
                        withAnimation {
                            self.curStage = .hello
                        }
                    })
                .transition(getCurTransition())
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
                .transition(getCurTransition())
            case .network:
                NetworkScreen(onNext: { _ in
                    withAnimation {
                        curStage = .loginQuery;
                    }
                })
                .transition(getCurTransition())
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
                .transition(getCurTransition())
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
