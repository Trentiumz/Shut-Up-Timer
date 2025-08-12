import SwiftUI;
import FamilyControls

struct SettingsView : View {
    // current settings
    @EnvironmentObject var settings: Settings;
    @EnvironmentObject var credManager: CredManager;
    @EnvironmentObject var router: AppRouter;
    @EnvironmentObject var curUser: CurUser
    
    func updateUsername(newUsername: String) {
        guard (credManager.session?.user.id) != nil else { return }
        
        Task {
            do {
                // Call the change_username function
                try await credManager.supabaseClient.rpc("change_username", params: ["new_username": newUsername]).execute()

                curUser.refresh()
            } catch {
                print("Error updating username: \(error)")
            }
        }
    }
    
    func updateVisibility(field: String, newValue: Bool) {
        // Update server state
        Task {
            do {
                try await credManager.supabaseClient.rpc("update_\(field)_visibility", params: ["new_\(field)_visible": newValue]).execute()
                curUser.refresh()
            } catch {
                print("Error updating \(field) visibility: \(error)")
                curUser.refresh()
            }
        }
    }
    
    var body: some View {
        VStack {
            TimerSettings()
            
            AppBlockSettings()
            
            // User Profile Section
            if credManager.loggedIn, let publicProfile = curUser.userPublicProfile, let privateProfile = curUser.userProfile {
                AccountSettings(
                    publicProfile: publicProfile,
                    privateProfile: privateProfile,
                    updateUsername: updateUsername,
                    updateVisibility: updateVisibility,
                    toLogout: {
                        Task {
                            do {
                                try await credManager.logOut();
                                curUser.refresh()
                            } catch {
                                print("Error signing out: \(error)")
                            }
                        }
                    });
            } else {
                SettingButton(text: "Log In", onSelect: { router.toLogin(onSuccess: {} )})
            }
        }
        .padding()
    }
    
    struct AccountSettings : View {
        @State private var usernameDisplay: String = "";
        var publicProfile: UserPublicProfileResponse;
        var privateProfile: UserProfileResponse;
        var updateUsername: (String) -> Void;
        var updateVisibility: (_: String, _: Bool) -> Void;
        var toLogout: () -> Void;
        
        var body : some View {
            VStack {
                ZStack(alignment: .top) {
                    FormattedImages.LinedImageBackground(width: 350)
                    VStack(spacing: 20) {
                        HStack {
                            AccountView.SectionStripe("Account")
                            Spacer()
                        }
                        // Username editing section
                        HStack {
                            SettingLabel("Set Username: ")
                            TextField("Username", text: $usernameDisplay, onCommit: { updateUsername(usernameDisplay) })
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        HStack {
                            SettingLabel("Private Mode: ")
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { !privateProfile.is_public_profile_visible },
                                set: { updateVisibility( "public_profile", !$0) }
                            ))
                        }
                        
                        SettingButton(text: "Log Out", onSelect: toLogout)
                    }
                    .padding(.leading, 45)
                    .padding(.trailing, 10)
                    .padding(.top, 5)
                    .padding(.bottom, 5)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                }
            }.frame(width: 350, height: 240)
        }
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
                                    StylizedOption(onClick: { 
                                        let oldValue = settings.difficulty.rawValue
                                        settings.difficulty = difficulty
                                        AnalyticsManager.shared.trackDifficultyChanged(from: oldValue, to: difficulty.rawValue)
                                    }, text: difficulty.rawValue.capitalized)
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
                                    StylizedOption(onClick: { 
                                        let oldValue = settings.roastLevel.rawValue
                                        settings.roastLevel = level
                                        AnalyticsManager.shared.trackRoastLevelChanged(from: oldValue, to: level.rawValue)
                                    }, text: level.rawValue.capitalized)
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
                }.frame(width: 350, height: 240)
            }
        }
    }
    
    struct AppBlockSettings: View {
        @EnvironmentObject var settings: Settings;
        @State private var showAppPicker = false
        @State private var showMonitorPicker = false
        
        var body: some View {
            VStack {
                ZStack(alignment: .top) {
                    FormattedImages.LinedImageBackground(width: 350)
                    VStack {
                        HStack {
                            AccountView.SectionStripe("App Blocking >")
                            Spacer()
                        }
                        
                        // App blocking selector
                        HStack {
                            SettingLabel("Apps to Block")
                            Spacer()
                            Button(action: {
                                showAppPicker = true
                            }) {
                                StylizedLabel("Select")
                            }
                        }
                        .familyActivityPicker(isPresented: $showAppPicker, selection: $settings.defaultBlockedApps)
                        
                        Spacer()
                            .frame(maxHeight: 8)
                        
                        // TODO: Add app monitoring
                        /*
                        // App blocking selector
                        HStack {
                            SettingLabel("Apps to Monitor")
                            Spacer()
                            Button(action: {
                                showMonitorPicker = true
                            }) {
                                StylizedLabel("Select")
                            }
                        }
                        .familyActivityPicker(isPresented: $showMonitorPicker, selection: $settings.appsToMonitor)
                         */
                        
                        Spacer()
                    }
                    .padding(.leading, 45)
                    .padding(.trailing, 10)
                    .padding(.top, 5)
                    .padding(.bottom, 5)
                }.frame(width: 350, height: 240)
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
    
    struct SettingButton: View {
        var text: String;
        var onSelect: () -> Void;
        
        var body : some View {
            Button(action: {
                onSelect();
            }){
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 280, height: 40)
                        .background(ColorTokens.red300)
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .inset(by: 1)
                                .stroke(ColorTokens.shade700, lineWidth: 2)
                        )
                    Text(text)
                        .font(Font.custom("ArchitectsDaughter-Regular", size: 30))
                        .foregroundColor(ColorTokens.shade100)
                        .frame(width: 230, height: 30)
                        .minimumScaleFactor(0.2)
                        .lineLimit(2)
                }
            }
        }
    }
}

struct SettingsPreview : PreviewProvider {
    
    struct Wrapper : View {
        @State var userPublicProfile: UserPublicProfileResponse? = nil;
        @State var userProfile: UserProfileResponse? = nil;
        var credManager = CredManager(subscriptionManager: SubscriptionManager())
        
        var body : some View {
            SettingsView()
            .environmentObject(AppRouter())
            .environmentObject(SettingsLoader.loadSettings())
            .environmentObject(credManager)
            .environmentObject(CurUser(credManager: credManager))
        }
    }
    
    static var previews : some View {
        Wrapper()
        
    }
}
