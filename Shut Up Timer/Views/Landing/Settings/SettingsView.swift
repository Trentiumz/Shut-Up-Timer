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
            case "username":
                profile.is_username_visible = newValue
            case "iq":
                profile.is_iq_visible = newValue
            case "profile_picture":
                profile.is_profile_picture_visible = newValue
            case "roasts":
                profile.is_roasts_visible = newValue
            case "disappointment":
                profile.is_disappointment_visible = newValue
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
                            Toggle("Show Username", isOn: Binding(
                                get: { privateProfile.is_username_visible },
                                set: { updateVisibility(field: "username", newValue: $0) }
                            ))
                            Toggle("Show IQ", isOn: Binding(
                                get: { privateProfile.is_iq_visible },
                                set: { updateVisibility(field: "iq", newValue: $0) }
                            ))
                            Toggle("Show Profile Picture", isOn: Binding(
                                get: { privateProfile.is_profile_picture_visible },
                                set: { updateVisibility(field: "profile_picture", newValue: $0) }
                            ))
                            Toggle("Show Roasts", isOn: Binding(
                                get: { privateProfile.is_roasts_visible },
                                set: { updateVisibility(field: "roasts", newValue: $0) }
                            ))
                            Toggle("Show Disappointment", isOn: Binding(
                                get: { privateProfile.is_disappointment_visible },
                                set: { updateVisibility(field: "disappointment", newValue: $0) }
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
} 