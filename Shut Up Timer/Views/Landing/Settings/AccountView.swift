import SwiftUI;

struct AccountView : View {
    // current settings
    @EnvironmentObject var settings: Settings;
    @EnvironmentObject var credManager: CredManager;
    @EnvironmentObject var router: AppRouter;
    
    init() {
    }
    
    var body: some View {
        VStack {
            // difficulty selector
            HStack {
                Text("Difficulty")
                Spacer()
                Picker("Difficulty", selection: $settings.difficulty) {
                    ForEach(Difficulty.allCases) { difficulty in
                        Text(difficulty.rawValue.capitalized).tag(difficulty)
                    }
                }
                .pickerStyle(.menu)
            }
            // roast level selector
            HStack {
                Text("Roast Level")
                Spacer()
                Picker("Difficulty", selection: $settings.roastLevel) {
                    ForEach(RoastLevel.allCases) { level in
                        Text(level.rawValue.capitalized).tag(level)
                    }
                }
                .pickerStyle(.menu)
            }
            
            TimerSelector(param: $settings.timerParam)
            
            // Login/Logout button
            HStack {
                Spacer()
                if credManager.loggedIn {
                    Button(action: {
                        Task {
                            do {
                                try await credManager.supabaseClient.auth.signOut()
                                await MainActor.run {
                                    credManager.loggedIn = false
                                    credManager.session = nil
                                }
                            } catch {
                                print("Error signing out: \(error)")
                            }
                        }
                    }) {
                        Text("Log Out")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                } else {
                    Button(action: {
                        router.toLogin(onSuccess: {})
                    }) {
                        Text("Log In")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    AccountView();
}
