import SwiftUI

struct OnboardingV2View: View {
    enum OnboardingStage {
        case screen1
        case screen2
        case screen3
        case screen5
    }
    
    private var onDone: () -> Void
    @State private var curStage: OnboardingStage = .screen1
    @Namespace private var transitionNS
    
    // Transition animation for screens coming from right and exiting to left
    private let screenTransition = AnyTransition.asymmetric(
        insertion: AnyTransition.move(edge: .trailing),
        removal: AnyTransition.move(edge: .leading)
    )
    
    init(onDone: @escaping () -> Void) {
        self.onDone = onDone
    }
    
    var body: some View {
        ZStack {
            // Background
            Background()
            
            // Current screen content
            switch curStage {
            case .screen1:
                OnboardingV2Screen1(
                    transitionToNext: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            curStage = .screen2
                        }
                    }
                )
                .transition(screenTransition)
                
            case .screen2:
                OnboardingV2Screen2(
                    transitionToNext: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            curStage = .screen3
                        }
                    }
                )
                .transition(screenTransition)
                
            case .screen3:
                OnboardingV2Screen3(
                    transitionToNext: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            curStage = .screen5
                        }
                    }
                )
                .transition(screenTransition)
                
            case .screen5:
                OnboardingV2Screen5(
                    transitionToNext: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            onDone()
                        }
                    }
                )
                .transition(screenTransition)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: curStage)
    }
}

#Preview {
    OnboardingV2View(onDone: {})
}
