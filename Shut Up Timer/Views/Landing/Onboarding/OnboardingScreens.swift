import SwiftUI;

struct OnboardingSelector : View {
    var text: String;
    var onPress: () -> Void;
    
    var body : some View {
        Button(action: onPress) {
            Text(text)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray)
                .foregroundStyle(.white)
                .cornerRadius(10)
        }
    }
}

struct DifficultyScreen : View {
    var onNext: (Difficulty) -> Void;
    
    func selectDifficulty(difficulty: Difficulty) {
        onNext(difficulty);
    }
    
    var body : some View {
        VStack {
            Rectangle()
                .frame(width: 200, height: 200)
                .foregroundStyle(.red)
            OnboardingSelector(text: "Easy Mode", onPress: {
                selectDifficulty(difficulty: .easy)
            })
            OnboardingSelector(text: "Medium Mode", onPress: {
                selectDifficulty(difficulty: .medium)
            })
            OnboardingSelector(text: "Asian Mode", onPress: {
                selectDifficulty(difficulty: .asian)
            })
        }.padding(.horizontal)
    }
}

enum LoginQuerySelection {
    case study;
    case login;
}

struct LoginQueryView : View {
    var onNext: (LoginQuerySelection) -> Void;
    
    func selectScreen(selection: LoginQuerySelection) {
        onNext(selection);
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 200x200 Red Rectangle
            Rectangle()
                .fill(Color.red)
                .frame(width: 200, height: 200)
                .cornerRadius(10)
            
            // Subheading
            Text("Shut up Timer.")
                .font(.title2)
                .fontWeight(.bold)
            
            // Body Text
            Text("Get cooked or get to studying")
                .font(.body)
                .foregroundStyle(.secondary)
            
            // Onboarding Selectors (Buttons)
            OnboardingSelector(text: "Study", onPress: {
                selectScreen(selection: .study)
            })
            OnboardingSelector(text: "Log in", onPress: {
                selectScreen(selection: .login)
            })
        }
        .padding()
    }
}

#Preview {
    OnboardingView(onDone: {})
}
