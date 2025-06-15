import SwiftUI;

struct SettingsView : View {
    // current settings
    @EnvironmentObject var settings: Settings;
    @EnvironmentObject var credManager: CredManager;
    @EnvironmentObject var router: AppRouter;
    
    // Profile data
    @Binding var userPublicProfile: UserPublicProfileResponse?;
    @Binding var userProfile: UserProfileResponse?;
    @State private var usernameDisplay: String = "";
    
    // Callbacks
    let updateUserProfile: () -> Void;
    
    func updateUsername() {
        guard (credManager.session?.user.id) != nil else { return }
        
        Task {
            do {
                // Call the change_username function
                try await credManager.supabaseClient.rpc("change_username", params: ["new_username": usernameDisplay]).execute()
                
                // Update local profile
                if var profile = userPublicProfile {
                    profile.username = usernameDisplay
                    await MainActor.run {
                        userPublicProfile = profile
                    }
                }
                
                // Fetch fresh profile data
                updateUserProfile()
            } catch {
                print("Error updating username: \(error)")
            }
        }
    }
    
    func updateVisibility(field: String, newValue: Bool) {
        // Update local state immediately
        if var profile = userProfile {
            switch field {
            case "public_profile":
                profile.is_public_profile_visible = newValue
            default:
                break
            }
            userProfile = profile
        }
        
        // Update server state
        Task {
            do {
                try await credManager.supabaseClient.rpc("update_\(field)_visibility", params: ["new_\(field)_visible": newValue]).execute()
                await MainActor.run {
                    updateUserProfile()
                }
            } catch {
                print("Error updating \(field) visibility: \(error)")
                // Revert local state if server update fails
                await MainActor.run {
                    updateUserProfile()
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            TimerSettings()
            
            // Login/Logout button
            HStack {
                Spacer()
                if credManager.loggedIn {
                    Button(action: {
                        Task {
                            do {
                                try await credManager.logOut();
                                userPublicProfile = nil;
                                userProfile = nil;
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
            if credManager.loggedIn, let publicProfile = userPublicProfile, let privateProfile = userProfile {
                VStack(spacing: 20) {
                    // Username editing section
                    HStack {
                        Text("Username:")
                        TextField("Username", text: $usernameDisplay, onCommit: updateUsername)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    // Profile Picture
                    if !publicProfile.profile_picture.isEmpty {
                        AsyncImage(url: URL(string: publicProfile.profile_picture)) { image in
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
                        Text("Username: \(publicProfile.username)")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("IQ: \(publicProfile.iq)")
                                .font(.title2)
                        }
                        
                        // Friend Code
                        HStack {
                            Image(systemName: "person.2.fill")
                                .foregroundColor(.blue)
                            Text("Friend Code: \(privateProfile.friend_code)")
                                .font(.title3)
                        }
                        
                        // Privacy Settings
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Privacy Settings")
                                .font(.headline)
                                .padding(.top)
                            
                            Toggle("Public Profile", isOn: Binding(
                                get: { privateProfile.is_public_profile_visible },
                                set: { updateVisibility(field: "public_profile", newValue: $0) }
                            ))
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
            }
        }
        .padding()
    }
    
    struct TimerSettings: View {
        @EnvironmentObject var settings: Settings;
        
        var body : some View {
            VStack {
                ZStack(alignment: .top) {
                    FormattedImages.LinedImageBackground(width: 350)
                    VStack {
                        HStack {
                            AccountView.SectionStripe("Timer >")
                            Spacer()
                        }
                        // difficulty selector
                        HStack {
                            SettingLabel("Difficulty")
                            Spacer()
                            Menu {
                                ForEach(Difficulty.allCases) { difficulty in
                                    StylizedOption(onClick: { settings.difficulty = difficulty}, text: difficulty.rawValue.capitalized)
                                        .tag(difficulty)
                                }
                            } label: {
                                StylizedLabel(settings.difficulty.rawValue.capitalized)
                            }
                        }
                        // roast level selector
                        HStack {
                            SettingLabel("Roast Level")
                            Spacer()
                            Menu {
                                ForEach(RoastLevel.allCases) { level in
                                    StylizedOption(onClick: { settings.roastLevel = level}, text: level.rawValue.capitalized)
                                        .tag(level)
                                }
                            } label: {
                                StylizedLabel(settings.roastLevel.rawValue.capitalized)
                            }
                        }
                        TimerSelector(param: $settings.timerParam)
                        Spacer()
                    }
                    .padding(.leading, 45)
                    .padding(.trailing, 10)
                    .padding(.top, 5)
                    .padding(.bottom, 5)
                }.frame(width: 350, height: 220)
            }
        }
    }
    
    struct SettingLabel: View {
        var message: String;
        init(_ message: String) {
            self.message = message
        }
        
        var body : some View {
            Text(message)
                .font(FontTokens.architectsDaughter(size: 18))
                .foregroundColor(ColorTokens.shade700)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .frame(alignment: .topLeading)
        }
    }
    
    struct StylizedOption : View {
        var onClick: () -> Void;
        var text: String;
        
        var body : some View {
            Button {
                onClick();
            } label: {
                Text(text)
                    .font(FontTokens.architectsDaughter(size: 20))
                    .foregroundStyle(ColorTokens.shade700)
            }
        }
    }

    struct StylizedLabel : View {
        var text: String;
        init(_ text: String) {
            self.text = text;
        }
        
        var body : some View {
            Text(text)
                .font(FontTokens.architectsDaughter(size: 20))
                .foregroundStyle(ColorTokens.shade700)
                .frame(width: 130)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ColorTokens.shade300)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ColorTokens.shade700, lineWidth: 1)
                )
        }
    }
}

struct SettingsPreview : PreviewProvider {
    
    struct Wrapper : View {
        @State var userPublicProfile: UserPublicProfileResponse? = nil;
        @State var userProfile: UserProfileResponse? = nil;
        
        var body : some View {
            SettingsView(
                userPublicProfile: $userPublicProfile,
                userProfile: $userProfile,
                updateUserProfile: {}
            )
            .environmentObject(AppRouter())
            .environmentObject(SettingsLoader.loadSettings(onUpdate: {_ in }))
            .environmentObject(SessionsLoader.loadSessions(onUpdate: {_ in }))
            .environmentObject(ToDoLoader.getToDo(onUpdate: { _ in }))
            .environmentObject(CredManager())
        }
    }
    
    static var previews : some View {
        Wrapper()
        
    }
}
