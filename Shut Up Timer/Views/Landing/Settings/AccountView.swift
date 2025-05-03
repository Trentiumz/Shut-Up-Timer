import SwiftUI;

struct AccountView : View {
    // current settings
    @EnvironmentObject var settings: Settings;
    @EnvironmentObject var credManager: CredManager;
    @EnvironmentObject var router: AppRouter;
    @State private var userProfile: UserPublicProfileResponse? = nil;
    
    init() {
    }

    func updateUserProfile() {
        Task {
            do {
                if let userId = credManager.session?.user.id {
                    let profile: [UserPublicProfileResponse] = try await credManager.supabaseClient.rpc("get_user_public_profile", params: ["user_id": userId]).execute().value
                    await MainActor.run {
                        userProfile = profile[0]
                    }
                }
            } catch {
                print("Error fetching user profile: \(error)")
            }
        }
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
                                    userProfile = nil
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
            
            // User Profile Section
            if credManager.loggedIn, let profile = userProfile {
                VStack(spacing: 20) {
                    // Profile Picture
                    if !profile.profile_picture.isEmpty {
                        AsyncImage(url: URL(string: profile.profile_picture)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } placeholder: {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 100, height: 100)
                        }
                    }
                    
                    // Username and IQ
                    VStack(spacing: 10) {
                        Text(profile.username)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("IQ: \(profile.iq)")
                                .font(.title2)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
            }
        }
        .padding()
        .onAppear {
            updateUserProfile()
        }.onChange(of: credManager.session) {
            updateUserProfile()
        }
    }
}

#Preview {
    AccountView();
}
