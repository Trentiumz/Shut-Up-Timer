import SwiftUI
struct OnboardingView : View {
    enum OnboardingStage {
        case difficulty;
        case network;
        case loginQuery;
        case login;
        case register;
    }
    
    private var onDone: () -> Void;
    @State private var curStage: OnboardingStage;
    @EnvironmentObject var settings: Settings;
    @EnvironmentObject var credManager: CredManager;
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
                        curStage = .network;
                    }
                })
                .transition(.move(edge: .trailing))
            case .network:
                NetworkScreen(onNext: { _ in
                    withAnimation {
                        curStage = .loginQuery;
                    }
                })
                .transition(.move(edge: .trailing))
            case .loginQuery:
                LoginQueryView(onNext: { selection in
                    withAnimation {
                        switch selection {
                        case .study:
                            onDone()
                        case .login:
                            curStage = .login
                        }
                    }
                })
                .transition(.move(edge: .trailing))
            case .login:
                LoginView(
                    onLoggedIn: {
                        withAnimation {
                            onDone()
                        }
                    },
                    onRegister: {
                        withAnimation {
                            curStage = .register
                        }
                    }
                )
                .transition(.move(edge: .trailing))
            case .register:
                RegisterView(
                    onRegistered: {
                        withAnimation {
                            onDone()
                        }
                    },
                    onLogin: {
                        withAnimation {
                            curStage = .login
                        }
                    }
                )
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut, value: curStage);
    }
}
