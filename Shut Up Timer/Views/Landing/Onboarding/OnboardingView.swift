import SwiftUI
struct OnboardingView : View {
    enum OnboardingStage {
        case hello;
        case answerForMe;
        case hours;
        case network;
        case roastLevel;
        case difficulty;
        case qInfo1;
        case loginQuery;
    }
    
    private var onDone: () -> Void;
    @State private var curStage: OnboardingStage;
    @EnvironmentObject var settings: Settings;
    @EnvironmentObject var router: AppRouter;
    @Namespace private var transitionNS;
    // temporary variable to keep track of whether the next transition should be rightward or left
    @State private var transitionRight = true;
    
    private let rightwardAnimation = AnyTransition.asymmetric(
        insertion: AnyTransition.move(edge: .trailing),
        removal: AnyTransition.move(edge: .leading)
    )
    private let leftwardAnimation = AnyTransition.asymmetric(
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
    private func transitionRightTo(_ to: OnboardingStage) {
        transitionRight = true;
        withAnimation {
            curStage = to;
        }
    }
    private func transitionLeftTo(_ to: OnboardingStage) {
        transitionRight = false;
        withAnimation {
            curStage = to;
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
                        transitionRightTo(.answerForMe)
                    },
                    onPrevious: nil)
                .transition(getCurTransition())
            case .answerForMe:
                OnboardingHello(
                    infoText: "Answer 5 questions for me lah",
                    buttonText: "Yes Mother!",
                    onPress: {
                        transitionRightTo(.hours)
                    },
                    onPrevious: {
                        transitionLeftTo(.hello)
                    })
                .transition(getCurTransition())
            case .hours:
                OnboardingQ1(
                    onPress: { val in
                        UserDefaults.standard.set(val, forKey: "onboarding-hours")
                        transitionRightTo(.network);
                    },
                    onPrevious: {
                        transitionLeftTo(.answerForMe)
                    })
                .transition(getCurTransition())
            case .network:
                OnboardingQ2(
                    onPress: { val in
                        UserDefaults.standard.set(val, forKey: "onboarding-network")
                        transitionRightTo(.roastLevel)
                    },
                    onPrevious: {
                        transitionLeftTo(.hours)
                    }
                )
                .transition(getCurTransition())
            case .roastLevel:
                OnboardingQ3(
                    onPress: { val in
                        settings.roastLevel = switch(val) {
                        case "low": .low;
                        case "med": .med;
                        case "high": .high;
                        default: .low
                        }
                        transitionRightTo(.difficulty)
                    },
                    onPrevious: {
                        transitionLeftTo(.network)
                    }
                )
                .transition(getCurTransition())
            case .difficulty:
                OnboardingQ4(
                    onPress: { val in
                        settings.difficulty = switch(val) {
                        case "easy": .easy;
                        case "medium": .medium;
                        case "asian": .asian;
                        default: .easy
                        }
                        transitionRightTo(.qInfo1);
                    },
                    onPrevious: {
                        transitionLeftTo(.roastLevel);
                    }
                )
                .transition(getCurTransition())
            case .qInfo1:
                OnboardingInfo1(onPress: {
                    transitionRightTo(.loginQuery)
                }, onPrevious: {
                    transitionLeftTo(.difficulty)
                })
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
        .environmentObject(SessionsLoader.loadSessions())
}
