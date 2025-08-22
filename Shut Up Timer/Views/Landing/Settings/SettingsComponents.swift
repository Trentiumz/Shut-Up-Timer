import SwiftUI
import FamilyControls
import _PhotosUI_SwiftUI

extension View {
    func textStroke(_ color: Color, lineWidth: CGFloat = 1) -> some View {
        self
            .shadow(color: color, radius: 0, x: lineWidth, y: 0)
            .shadow(color: color, radius: 0, x: -lineWidth, y: 0)
            .shadow(color: color, radius: 0, x: 0, y: lineWidth)
            .shadow(color: color, radius: 0, x: 0, y: -lineWidth)
    }
}

// MARK: - Settings Components Extensions

extension SettingsView {
    
    // MARK: - Figma Design Components
    
    struct UserProfileCard: View {
        @EnvironmentObject var curUser: CurUser
        @EnvironmentObject var credManager: CredManager
        @Binding var selectedTab: SettingsTab
        let userIQ: Int
        
        @State private var pickedImage: PhotosPickerItem?
        @State private var showFailAlert: Bool = false
        @State private var uploading: Bool = false
        
        var body: some View {
            VStack(spacing: 0) {
                UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20)
                    .fill(ColorTokens.shade600)
                    .stroke(ColorTokens.shade100, lineWidth: 2)
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .overlay(
                        Image(uiImage: FormattedImages.Image183)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 30)
                            .padding(.vertical, -15)
                        ,
                        alignment: .top
                    )
                    .overlay(
                        HStack(spacing: 15) {
                            // Profile picture with PhotosPicker
                            if let publicProfile = curUser.userPublicProfile {
                                PhotosPicker(
                                    selection: $pickedImage,
                                    matching: .images,
                                    photoLibrary: .shared()
                                ) {
                                    PFPDisplay(url: publicProfile.profile_picture, width: 50, height: 50)
                                        .opacity(uploading ? 0.5 : 1)
                                }
                                .onChange(of: pickedImage) { newVal in
                                    Task {
                                        await MainActor.run {
                                            withAnimation {
                                                uploading = true
                                            }
                                        }
                                        if let data = try? await newVal?.loadTransferable(type: Data.self),
                                           let image = UIImage(data: data)
                                        {
                                            let success = await credManager.uploadPFP(image: image)
                                            if success {
                                                curUser.refresh()
                                            } else {
                                                showFailAlert = true
                                            }
                                        }
                                        await MainActor.run {
                                            withAnimation {
                                                uploading = false
                                            }
                                        }
                                    }
                                }
                                .alert("Oops!", isPresented: $showFailAlert) {
                                    Button("OK", role: .cancel) {}
                                } message: {
                                    Text("We couldn't update your profile picture")
                                }
                            } else {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 50, height: 50)
                            }
                            
                            if let username = curUser.userPublicProfile?.username {
                                Text(username)
                                    .font(FontTokens.architectsDaughter(size: 28))
                                    .foregroundColor(ColorTokens.shade100)
                                    .textStroke(ColorTokens.shade700, lineWidth: 1.5)
                            } else {
                                Text("Please Login")
                                    .font(.system(size: 28, weight: .medium))
                                    .foregroundColor(ColorTokens.shade100)
                                    .textStroke(ColorTokens.shade700, lineWidth: 1.5)
                            }
                            
                            Spacer()
                        }
                            .padding(.horizontal, 20)
                            .padding(.bottom, -15),
                        alignment: .bottom
                    )
                    .zIndex(2)
                
                TabSelectionHalf(selectedTab: $selectedTab, userIQ: userIQ)
            }
        }
    }
    
    fileprivate struct TabSelectionHalf : View {
        @Binding var selectedTab: SettingsTab
        let userIQ: Int
        
        @Namespace var iqAnimation
        
        var body: some View {
            UnevenRoundedRectangle(bottomLeadingRadius: 20, bottomTrailingRadius: 20)
                .fill(ColorTokens.shade300)
                .stroke(ColorTokens.shade100, lineWidth: 2)
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .overlay (
                    HStack(spacing: 0) {
                        Spacer()
                        ForEach(SettingsTab.allCases, id: \.self) { tab in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedTab = tab
                                }
                            }) {
                                Text(tab.title)
                                    .font(FontTokens.architectsDaughter(size: 18))
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                    .foregroundColor(ColorTokens.shade100)
                                    .textStroke(ColorTokens.shade700, lineWidth: 0.75)
                                    .overlay(
                                        Group {
                                            Text("\(userIQ) IQ")
                                                .font(FontTokens.architectsDaughter(size: 16))
                                                .foregroundColor(ColorTokens.shade700)
                                                .frame(width: 75)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .fill(ColorTokens.shade100)
                                                        .stroke(ColorTokens.shade700)
                                                )
                                                .opacity(selectedTab == tab ? 1 : 0)
                                                .allowsHitTesting(selectedTab == tab)
                                                .matchedGeometryEffect(id: "iq-animation", in: iqAnimation, isSource: selectedTab == tab)
                                        }
                                            .frame(height: 0, alignment: .top)
                                            .offset(y: 10)
                                        ,
                                        alignment: .bottom
                                    )
                            }
                            Spacer()
                        }
                    }
                        .padding(.bottom, 15)
                    ,
                    alignment: .bottom
                )
        }
    }
    
    struct MainContentCard: View {
        let selectedTab: SettingsTab
        @Binding var showUsernameModal: Bool
        let updateUsername: (String) -> Void
        let updateVisibility: (String, Bool) -> Void
        let toLogout: () -> Void
        
        var body: some View {
            // Content based on selected tab
            switch selectedTab {
            case .timer:
                TimerTypesContent()
            case .blockedApps:
                BlockedCategoriesContent()
            case .account:
                MyAccountContent(
                    showUsernameModal: $showUsernameModal,
                    updateUsername: updateUsername,
                    updateVisibility: updateVisibility,
                    toLogout: toLogout
                )
            }
        }
    }
    
    struct TimerTypeButton: View {
        let title: String
        let isSelected: Bool
        let onSelect: () -> Void
        
        var body: some View {
            Button(action: onSelect) {
                HStack {
                    Text(title)
                        .font(FontTokens.architectsDaughter(size: 16))
                        .foregroundColor(ColorTokens.shade700)
                    Spacer()
                    Circle()
                        .fill(isSelected ? ColorTokens.green500 : Color.clear)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(ColorTokens.shade700, lineWidth: 1)
                        )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(ColorTokens.shade400, lineWidth: 1)
                )
            }
        }
    }
    
    struct BlockedCategoriesContent: View {
        @EnvironmentObject var settings: Settings
        @State private var showAppPicker = false
        @State private var authorizationStatus: FamilyControls.AuthorizationStatus = .notDetermined
        
        var body: some View {
            VStack(spacing: 20) {
                if authorizationStatus == .approved {
                    // User has permissions, show app picker
                    HStack {
                        SettingsView.SettingLabel("Apps to Block")
                        Spacer()
                        Button(action: {
                            showAppPicker = true
                        }) {
                            SettingsView.StylizedLabel("Select")
                        }
                    }
                    .familyActivityPicker(isPresented: $showAppPicker, selection: $settings.defaultBlockedApps)
                    .frame(minHeight: 200)
                } else {
                    // User doesn't have permissions, show permission request
                    VStack(spacing: 16) {
                        Text("Screen Time Permissions Required")
                            .font(FontTokens.architectsDaughter(size: 20))
                            .foregroundColor(ColorTokens.shade700)
                            .multilineTextAlignment(.center)
                        
                        Text("To block apps during your study sessions, you need to grant Screen Time permissions.")
                            .font(FontTokens.architectsDaughter(size: 16))
                            .foregroundColor(ColorTokens.shade600)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            Task {
                                do {
                                    try await FamilyControls.AuthorizationCenter.shared.requestAuthorization(for: .individual)
                                    authorizationStatus = FamilyControls.AuthorizationCenter.shared.authorizationStatus
                                } catch {
                                    print("Failed to request authorization: \(error)")
                                }
                            }
                        }) {
                            SettingsView.SettingButton(text: "Grant Permissions", onSelect: {})
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(ColorTokens.shade300)
                    .stroke(ColorTokens.shade100, lineWidth: 2)
            )
            .onAppear {
                authorizationStatus = FamilyControls.AuthorizationCenter.shared.authorizationStatus
            }
        }
    }
    
    struct MyAccountContent: View {
        @EnvironmentObject var credManager: CredManager
        @EnvironmentObject var curUser: CurUser
        @EnvironmentObject var router: AppRouter
        @EnvironmentObject var settings: Settings
        @EnvironmentObject var liveActivitManager: LiveActivityManager
        @Binding var showUsernameModal: Bool
        @State private var showLiveActivityInfo = false
        @State private var showDailyReminderInfo = false
        @State private var showCountdownPicker = false
        let updateUsername: (String) -> Void
        let updateVisibility: (String, Bool) -> Void
        let toLogout: () -> Void
        
        struct AccountSection: Identifiable, CustomStringConvertible, Equatable {
            var id: String { description }
            let description: String
        }
        
        static let accountSections = [
            AccountSection(description: "Login Info"),
            AccountSection(description: "Profile"),
            AccountSection(description: "Preferences")
        ]
        
        @State private var selectedSection: AccountSection = accountSections[0]
        
        var body: some View {
            if credManager.loggedIn, curUser.userPublicProfile != nil, let privateProfile = curUser.userProfile {
                SettingsView.SettingTabs(
                    heading: "My Account",
                    items: MyAccountContent.accountSections,
                    selectedItem: $selectedSection
                ) { section in
                    AccountSectionDetailView(
                        section: section,
                        privateProfile: privateProfile,
                        showUsernameModal: $showUsernameModal,
                        showLiveActivityInfo: $showLiveActivityInfo,
                        showDailyReminderInfo: $showDailyReminderInfo,
                        showCountdownPicker: $showCountdownPicker,
                        updateUsername: updateUsername,
                        updateVisibility: updateVisibility,
                        logout: toLogout
                    )
                }
            } else {
                // Not logged in - show login prompt
                VStack(spacing: 20) {
                    Text("My Account")
                        .font(FontTokens.architectsDaughter(size: 24))
                        .foregroundColor(ColorTokens.shade100)
                        .textStroke(ColorTokens.shade700, lineWidth: 1.5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 16) {
                        Text("Please log in to access your account settings")
                            .font(FontTokens.architectsDaughter(size: 18))
                            .foregroundColor(ColorTokens.shade700)
                            .multilineTextAlignment(.center)
                        
                        Button("Log In") {
                            router.toLogin(onSuccess: {})
                        }
                        .font(FontTokens.architectsDaughter(size: 20))
                        .foregroundColor(ColorTokens.shade100)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(ColorTokens.red300)
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(ColorTokens.shade100, lineWidth: 2)
                        )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(ColorTokens.shade600)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(ColorTokens.shade100, lineWidth: 2)
                )
            }
        }
    }
    
    struct AccountSectionDetailView: View {
        let section: MyAccountContent.AccountSection
        let privateProfile: UserProfileResponse
        @Binding var showUsernameModal: Bool
        @Binding var showLiveActivityInfo: Bool
        @Binding var showDailyReminderInfo: Bool
        @Binding var showCountdownPicker: Bool
        let updateUsername: (String) -> Void
        let updateVisibility: (String, Bool) -> Void
        let logout: () -> Void
        @EnvironmentObject var settings: Settings
        @EnvironmentObject var liveActivitManager: LiveActivityManager
        @EnvironmentObject var curUser: CurUser
        
        var body: some View {
            VStack(spacing: 16) {
                switch section.description {
                case "Login Info":
                    LoginInfoSection(
                        showUsernameModal: $showUsernameModal,
                        updateUsername: updateUsername,
                        logout: logout
                    )
                case "Profile":
                    ProfileSection(
                        privateProfile: privateProfile,
                        updateVisibility: updateVisibility
                    )
                case "Preferences":
                    PreferencesSection(
                        showLiveActivityInfo: $showLiveActivityInfo,
                        showDailyReminderInfo: $showDailyReminderInfo,
                        showCountdownPicker: $showCountdownPicker
                    )
                default:
                    EmptyView()
                }
            }
        }
    }
    
    struct LoginInfoSection: View {
        @Binding var showUsernameModal: Bool
        let updateUsername: (String) -> Void
        @EnvironmentObject var curUser: CurUser
        let logout: () -> Void
        
        var body: some View {
            VStack(spacing: 20) {
                // Username display and change
                HStack {
                    SettingsView.SettingLabel("Username")
                    Spacer()
                    Button(action: {
                        showUsernameModal = true
                    }) {
                        SettingsView.StylizedLabel(
                            curUser.userPublicProfile?.username.isEmpty == true ? "Set Username" : curUser.userPublicProfile?.username ?? "Unknown"
                        )
                    }
                }
                
                // Logout button
                Button("Logout") {
                    logout()
                }
                .font(FontTokens.architectsDaughter(size: 16))
                .foregroundColor(ColorTokens.shade100)
                .padding(.horizontal, 30)
                .padding(.vertical, 8)
                .background(ColorTokens.red300)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(ColorTokens.shade100, lineWidth: 2)
                )
            }
        }
    }
    
    struct ProfileSection: View {
        let privateProfile: UserProfileResponse
        let updateVisibility: (String, Bool) -> Void
        
        var body: some View {
            VStack(spacing: 20) {
                // Private Mode toggle
                SettingToggleRow(
                    title: "Private Mode",
                    isOn: Binding(
                        get: { !privateProfile.is_public_profile_visible },
                        set: { newValue in
                            updateVisibility("public_profile", !newValue)
                        }
                    )
                )
                
                // Additional profile settings can be added here
                Text("Profile settings allow you to control your privacy and visibility to other users.")
                    .font(FontTokens.architectsDaughter(size: 14))
                    .foregroundColor(ColorTokens.shade600)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    struct PreferencesSection: View {
        @Binding var showLiveActivityInfo: Bool
        @Binding var showDailyReminderInfo: Bool
        @Binding var showCountdownPicker: Bool
        @EnvironmentObject var settings: Settings
        @EnvironmentObject var liveActivitManager: LiveActivityManager
        @State private var showDifficultyOverlay: Bool = false
        
        func getDifficultyDescription(_ difficulty: Difficulty) -> String {
            switch difficulty {
            case .easy:
                return "A simple timer, easy for tracking!"
            case .medium:
                return "Blocks apps, but will fail you if you close the app >:("
            case .asian:
                return "Don't u dare leave this app."
            }
        }
        
        var body: some View {
            VStack(spacing: 20) {
                // Difficulty selection
                HStack {
                    SettingsView.SettingLabel("Difficulty")
                    Spacer()
                    Menu {
                        ForEach(Difficulty.allCases) { difficulty in
                            SettingsView.StylizedOption(onClick: { 
                                let oldValue = settings.difficulty.rawValue
                                settings.difficulty = difficulty
                                showDifficultyOverlay = true
                                AnalyticsManager.shared.trackDifficultyChanged(from: oldValue, to: difficulty.rawValue)
                            }, text: difficulty.rawValue.capitalized)
                                .tag(difficulty)
                        }
                    } label: {
                        SettingsView.StylizedLabel(settings.difficulty.rawValue.capitalized)
                    }
                }
                .alert("Difficulty Changed", isPresented: $showDifficultyOverlay) {
                    Button("Got it!", role: .cancel) { }
                } message: {
                    Text(getDifficultyDescription(settings.difficulty))
                }
                
                // Daily Reminder toggle
                SettingToggleRow(
                    title: "Daily Reminder",
                    isOn: Binding(
                        get: { settings.dailyBeckon },
                        set: { newValue in
                            settings.dailyBeckon = newValue
                            if newValue {
                                showDailyReminderInfo = true
                            }
                        }
                    )
                )
                .alert("Daily Reminder Enabled", isPresented: $showDailyReminderInfo) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Every day, you might get a couple messages telling you to study :)")
                }
                
                VStack(spacing: 5) {
                    // Live Activity Countdown toggle
                    SettingToggleRow(
                        title: "Live Activity Countdown",
                        isOn: Binding(
                            get: { liveActivitManager.settings.isEnabled },
                            set: { newValue in
                                if newValue {
                                    liveActivitManager.enableLiveActivity()
                                    showLiveActivityInfo = true
                                } else {
                                    liveActivitManager.disableLiveActivity()
                                }
                            }
                        )
                    )
                    .alert("Live Activity Enabled", isPresented: $showLiveActivityInfo) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("This automatically creates a live activity countdown from when you last studied.")
                    }
                    
                    // Countdown Time picker (when Live Activity is enabled)
                    if liveActivitManager.settings.isEnabled {
                        HStack {
                            SettingsView.SettingLabel("Countdown Time")
                                .layoutPriority(2)
                            Spacer()
                                .layoutPriority(-2)
                            Spacer()
                                .frame(maxWidth: 20)
                            let countdownHours = max(1, Int(liveActivitManager.settings.durationParameter / 3600))
                            Button(action: { showCountdownPicker = true }) {
                                SettingsView.StylizedLabel("\(countdownHours) \(countdownHours == 1 ? "hour" : "hours")")
                            }
                            .sheet(isPresented: $showCountdownPicker) {
                                VStack(spacing: 16) {
                                    Text("Select Countdown Hours")
                                        .font(FontTokens.architectsDaughter(size: 22))
                                        .foregroundColor(ColorTokens.shade700)
                                    Picker(
                                        "Hours",
                                        selection: Binding<Int>(
                                            get: { countdownHours },
                                            set: { newValue in
                                                liveActivitManager.userRequestedTimeChange(newDuration: TimeInterval(newValue * 3600))
                                            }
                                        )
                                    ) {
                                        ForEach(1...24, id: \.self) { hour in
                                            Text("\(hour) \(hour == 1 ? "hour" : "hours")").tag(hour)
                                        }
                                    }
                                    .pickerStyle(WheelPickerStyle())
                                    Button("Done") { showCountdownPicker = false }
                                        .font(FontTokens.architectsDaughter(size: 20))
                                        .foregroundColor(ColorTokens.shade700)
                                }
                            }
                        }
                    }
                }
                
                // Description
                Text("Preferences allow you to customize your study experience and app behavior.")
                    .font(FontTokens.architectsDaughter(size: 14))
                    .foregroundColor(ColorTokens.shade600)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Container Components
    
    struct TabHeaderView: View {
        @Binding var selectedTab: SettingsTab
        let userIQ: Int
        
        var body: some View {
            VStack(spacing: 12) {
                // Tab buttons
                HStack(spacing: 8) {
                    ForEach(SettingsTab.allCases, id: \.self) { tab in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTab = tab
                            }
                        }) {
                            Text(tab.title)
                                .font(FontTokens.architectsDaughter(size: 16))
                                .foregroundColor(selectedTab == tab ? ColorTokens.shade100 : ColorTokens.shade700)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(selectedTab == tab ? ColorTokens.red300 : Color.clear)
                                )
                        }
                    }
                }
                
                // IQ Block that moves
                HStack {
                    // Calculate position based on selected tab
                    let tabWidth: CGFloat = 100 // Approximate width per tab
                    let offset: CGFloat = CGFloat(SettingsTab.allCases.firstIndex(of: selectedTab) ?? 0) * tabWidth
                    
                    Spacer()
                        .frame(width: max(0, offset - 40))
                    
                    VStack(spacing: 4) {
                        Text("\(userIQ)")
                            .font(FontTokens.architectsDaughter(size: 20))
                            .foregroundColor(ColorTokens.shade100)
                        Text("IQ")
                            .font(FontTokens.architectsDaughter(size: 14))
                            .foregroundColor(ColorTokens.shade100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ColorTokens.brown500)
                    )
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Timer Types Content
    
    struct TimerTypesContent: View {
        @EnvironmentObject var settings: Settings
        
        struct TimerGeneralType: Identifiable, CustomStringConvertible, Equatable {
            var id: String { description }
            
            let description: String
            let defaultVal: TimerType
        }
        
        static let timerGeneralTypes = [
            TimerGeneralType(description: "Pomodoro", defaultVal: .pomodoro(sessionTime: 25 * 60, breakTime: 5 * 60)),
            TimerGeneralType(description: "Countdown", defaultVal: .countdown(seconds: 60 * 60)),
            TimerGeneralType(description: "Stopwatch", defaultVal: .stopwatch)
        ]
        static func typeToGeneral(_ type: TimerType) -> TimerGeneralType {
            return switch(type) {
            case .pomodoro:
                timerGeneralTypes[0]
            case .countdown:
                timerGeneralTypes[1]
            case .stopwatch:
                timerGeneralTypes[2]
            }
        }
        
        var body: some View {
            SettingsView.SettingTabs(
                heading: "Timer Types",
                items: TimerTypesContent.timerGeneralTypes,
                selectedItem: Binding(
                    get: { TimerTypesContent.typeToGeneral(settings.timerType) },
                    set: {
                        settings.timerType = $0.defaultVal
                    }
                )
            ) { _ in
                TimerTypeDetailView()
            }
        }
    }
    
    struct TimerTypeDetailView: View {
        @EnvironmentObject private var settings: Settings
        
        var body: some View {
            VStack(spacing: 16) {
                // Timer type specific content
                switch settings.timerType {
                case .countdown(let seconds):
                    CountdownDetailView(
                        duration: Binding(
                            get: { seconds },
                            set: { newDuration in
                                if case .countdown = settings.timerType {
                                    settings.timerType = .countdown(seconds: newDuration)
                                }
                            }
                        )
                    )
                case .stopwatch:
                    StopwatchDetailView()
                case .pomodoro(let sessionTime, let breakTime):
                    PomodoroDetailView(
                        sessionTime: Binding(
                            get: { sessionTime },
                            set: { newSessionTime in
                                if case .pomodoro = settings.timerType {
                                    settings.timerType = .pomodoro(sessionTime: newSessionTime, breakTime: breakTime)
                                }
                            }
                        ),
                        breakTime: Binding(
                            get: { breakTime },
                            set: { newBreakTime in
                                if case .pomodoro = settings.timerType {
                                    settings.timerType = .pomodoro(sessionTime: sessionTime, breakTime: newBreakTime)
                                }
                            }
                        )
                    )
                }
            }
        }
        
        struct TimerDurationPickerButton: View {
            @State var showDurationPicker: Bool = false
            @Binding var duration: TimeInterval
            var durationStr: String {
                TimerTypeDetailView.durationToStr(duration)
            }
            
            var body: some View {
                Button(action: { showDurationPicker = true }) {
                    Text(durationStr)
                        .font(FontTokens.architectsDaughter(size: 24))
                        .foregroundColor(ColorTokens.shade100)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 4)
                        .background(                            RoundedRectangle(cornerRadius: 5)
                                .fill(ColorTokens.red300)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(ColorTokens.shade100, lineWidth: 2)
                        )
                }
                .sheet(isPresented: $showDurationPicker) {
                    DurationPickerModal(duration: $duration)
                }
            }
        }
        
        static func durationToStr(_ duration: TimeInterval) -> String {
            let hours = Int(duration) / 3600
            let minutes = (Int(duration) % 3600) / 60
            
            if hours > 0 {
                return "\(hours):\(String(format: "%02d", minutes))"
            } else {
                return "\(minutes) min"
            }
        }
    }
    
    struct CountdownDetailView: View {
        @Binding var duration: TimeInterval
        @State private var showDurationPicker = false
        
        var body: some View {
            VStack(spacing: 20) {
                // Main image
                Image(uiImage: FormattedImages.Image185)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 180)
                
                // Description
                Text("Count down from a specific time")
                    .font(FontTokens.architectsDaughter(size: 18))
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)
                    .foregroundColor(ColorTokens.shade100)
                    .multilineTextAlignment(.center)
                    .textStroke(ColorTokens.shade700, lineWidth: 0.75)
                
                HStack(alignment: .center) {
                    Text("Selected Time: ")
                        .font(FontTokens.architectsDaughter(size: 22))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundColor(ColorTokens.shade700)
                    
                    // Duration picker button
                    TimerTypeDetailView.TimerDurationPickerButton(duration: $duration)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    struct StopwatchDetailView: View {
        var body: some View {
            VStack(spacing: 20) {
                // Main image - using a placeholder since no specific stopwatch image
                Image(uiImage: FormattedImages.Image187)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 200)
                // Description
                Text("Study as long as you possibly can")
                    .font(FontTokens.architectsDaughter(size: 18))
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)
                    .foregroundColor(ColorTokens.shade100)
                    .multilineTextAlignment(.center)
                    .textStroke(ColorTokens.shade700, lineWidth: 0.75)
                
                // No configuration needed for stopwatch
                Text("No configuration needed")
                    .font(FontTokens.architectsDaughter(size: 14))
                    .foregroundColor(ColorTokens.shade600)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
        }
    }
    
    struct PomodoroDetailView: View {
        @Binding var sessionTime: TimeInterval
        @Binding var breakTime: TimeInterval
        @State private var showSessionPicker = false
        @State private var showBreakPicker = false
        
        var body: some View {
            VStack(spacing: 20) {
                // Main image - using tomato image
                Image(uiImage: FormattedImages.Image186)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 150)
                
                // Description
                Text("Study and rest in intervals")
                    .font(FontTokens.architectsDaughter(size: 18))
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)
                    .foregroundColor(ColorTokens.shade100)
                    .multilineTextAlignment(.center)
                    .textStroke(ColorTokens.shade700, lineWidth: 0.75)
                
                // Session time picker
                VStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Text("Session Time: ")
                            .font(FontTokens.architectsDaughter(size: 18))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .foregroundColor(ColorTokens.shade700)
                        
                        TimerTypeDetailView.TimerDurationPickerButton(duration: $sessionTime)
                    }
                    
                    // Break time picker
                    HStack(spacing: 8) {
                        Text("Break Time: ")
                            .font(FontTokens.architectsDaughter(size: 18))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .foregroundColor(ColorTokens.shade700)
                        
                        TimerTypeDetailView.TimerDurationPickerButton(duration: $breakTime)
                    }
                }
            }
            .padding(.horizontal, 10)
        }
    }
    
    // MARK: - Utility Components
    struct SettingToggleRow: View {
        let title: String
        @Binding var isOn: Bool
        
        var body: some View {
            HStack {
                Text(title)
                    .font(FontTokens.architectsDaughter(size: 16))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .layoutPriority(2)
                    .foregroundColor(ColorTokens.shade700)
                Spacer()
                    .layoutPriority(-1)
                Spacer()
                    .frame(maxWidth: 20)
                Toggle("", isOn: $isOn)
                    .tint(ColorTokens.green500)
            }
        }
    }
    
    struct UsernameEditModal: View {
        let currentUsername: String
        let onSave: (String) -> Void
        let onCancel: () -> Void
        
        @State private var newUsername: String = ""
        
        var body: some View {
            NavigationView {
                VStack(spacing: 20) {
                    Text("Change Username")
                        .font(FontTokens.architectsDaughter(size: 24))
                        .foregroundColor(ColorTokens.shade700)
                    
                    TextField("Enter new username", text: $newUsername)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(FontTokens.architectsDaughter(size: 18))
                    
                    HStack(spacing: 16) {
                        Button("Cancel") {
                            onCancel()
                        }
                        .font(FontTokens.architectsDaughter(size: 18))
                        .foregroundColor(ColorTokens.shade600)
                        
                        Button("Save") {
                            onSave(newUsername)
                        }
                        .font(FontTokens.architectsDaughter(size: 18))
                        .foregroundColor(ColorTokens.shade100)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(ColorTokens.red300)
                        .cornerRadius(20)
                        .disabled(newUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    Spacer()
                        .frame(maxHeight: 30)
                }
                .padding()
                .onAppear {
                    newUsername = currentUsername
                }
            }
        }
    }
    
    // MARK: - Legacy Components (for compatibility)
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
                .frame(width: 110)
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
    
    struct SettingLabel: View {
        var message: String;
        init(_ message: String) {
            self.message = message
        }
        
        var body : some View {
            Text(message)
                .font(FontTokens.architectsDaughter(size: 18))
                .foregroundColor(ColorTokens.shade700)
                .lineLimit(1)
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
    
    // MARK: - SettingTabs Component
    
    struct SettingTabs<Item, Content>: View where Item: CustomStringConvertible & Identifiable & Equatable, Content: View {
        let heading: String
        let items: [Item]
        let content: (Item) -> Content
        @Binding private var selectedItem: Item
        @State private var itemToShow: Item
        @State private var slideDirection: SlideDirection = .none
        
        enum SlideDirection {
            case left, right, none
        }
        
        init(heading: String, items: [Item], selectedItem: Binding<Item>, @ViewBuilder content: @escaping (Item) -> Content) {
            self.heading = heading
            self.items = items
            self.content = content
            self._selectedItem = selectedItem
            self.itemToShow = selectedItem.wrappedValue
        }
        
        var body: some View {
            VStack(spacing: 0) {
                // Heading
                Text(heading)
                    .font(FontTokens.architectsDaughter(size: 24))
                    .foregroundColor(ColorTokens.shade100)
                    .textStroke(ColorTokens.shade700, lineWidth: 1.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                
                Spacer()
                    .frame(maxHeight: 15)
                
                // Tab buttons
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(items) { item in
                            let isSelected = itemToShow.id == item.id
                            
                            Button(action: {
                                // Determine slide direction based on item order
                                if let currentIndex = items.firstIndex(of: selectedItem),
                                   let newIndex = items.firstIndex(of: item) {
                                    slideDirection = newIndex > currentIndex ? .left : .right
                                }
                                
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedItem = item
                                }
                            }) {
                                Text(String(describing: item))
                                    .font(FontTokens.architectsDaughter(size: 18))
                                    .minimumScaleFactor(0.7)
                                    .foregroundColor(isSelected ? ColorTokens.shade700 : ColorTokens.shade100)
                                    .lineLimit(1)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 3)
                                    .background(
                                        UnevenRoundedRectangle(topLeadingRadius: 10, topTrailingRadius: 10)
                                            .fill(isSelected ? ColorTokens.shade300 : ColorTokens.red300)
                                    )
                                    .overlay(
                                        UnevenRoundedRectangle(topLeadingRadius: 10, topTrailingRadius: 10)
                                            .stroke(ColorTokens.shade100, lineWidth: 2)
                                    )
                                    .overlay(alignment: .bottom) {
                                        if isSelected {
                                            Rectangle()
                                                .fill(ColorTokens.shade300)
                                                .frame(height: 3)
                                                .offset(y: 1.5)
                                        }
                                    }
                            }
                        }
                        
                        Spacer()
                    }
                    .zIndex(2)
                    
                    // Content area
                    ZStack {
                        ForEach(items) { item in
                            if itemToShow == item {
                                content(item)
                                    .id(item.description)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: slideDirection == .left ? .trailing : .leading).combined(with: .opacity),
                                        removal: .move(edge: slideDirection == .left ? .leading : .trailing).combined(with: .opacity)
                                    ))
                            }
                        }
                    }
                    .animation(.easeInOut, value: selectedItem)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        UnevenRoundedRectangle(bottomLeadingRadius: 10, bottomTrailingRadius: 10)
                            .fill(ColorTokens.shade300)
                    )
                    .overlay(
                        UnevenRoundedRectangle(bottomLeadingRadius: 10, bottomTrailingRadius: 10)
                            .stroke(ColorTokens.shade100, lineWidth: 2)
                    )
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(ColorTokens.shade600)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(ColorTokens.shade100, lineWidth: 2)
            )
            .onChange(of: selectedItem) { _ in
                withAnimation {
                    itemToShow = selectedItem
                }
            }
        }
    }
}

// MARK: - Preview

struct SettingsViewPreview : PreviewProvider {
    struct Wrapper: View {
        @State private var selectedTab: SettingsTab = .timer
        @State private var showUsernameModal: Bool = false
        private var credManager = CredManager(subscriptionManager: SubscriptionManager())
        
        var body: some View {
            ZStack {
                Color.black
                VStack(spacing: 0) {
                    Spacer()
                    
                    SettingsView.UserProfileCard(selectedTab: $selectedTab, userIQ: 200)
                        .zIndex(2)
                    
                    Spacer()
                        .frame(maxHeight: 10)
                    
                    // Preview different tabs
                    SettingsView.MainContentCard(
                        selectedTab: selectedTab,
                        showUsernameModal: $showUsernameModal,
                        updateUsername: { _ in },
                        updateVisibility: { _, _ in },
                        toLogout: {}
                    )
                    
                    Spacer()
                }
                .padding(.horizontal)
                .environmentObject(SettingsLoader.loadSettings())
                .environmentObject(credManager)
                .environmentObject(CurUser(credManager: credManager))
                .environmentObject(AppRouter())
            }
        }
    }
    
    static var previews: some View {
        SettingsViewPreview.Wrapper()
    }
}

// MARK: - SettingTabs Preview

struct SettingTabsPreview: PreviewProvider {
    // Sample data for preview
    struct TimerType: Identifiable, CustomStringConvertible, Equatable {
        var id: String { name }
        let name: String
        var description: String { name }
        let info: String
        
    }
    
    struct Wrapper: View {
        static let timerTypes = [
            TimerType(name: "Pomodoro", info: "25 minutes work, 5 minutes break"),
            TimerType(name: "Countdown", info: "5 minute quick sessions"),
            TimerType(name: "Stopwatch", info: "Set your own duration")
        ]
        
        @State var selectedItem: TimerType = Wrapper.timerTypes[0]
        
        var body: some View {
            ZStack {
                Color.black
                VStack(spacing: 20) {
                    Spacer()
                    
                    SettingsView.SettingTabs(
                        heading: "Timer Types",
                        items: Wrapper.timerTypes,
                        selectedItem: $selectedItem
                    ) { timerType in
                        VStack(spacing: 12) {
                            Text(timerType.name)
                                .font(FontTokens.architectsDaughter(size: 20))
                                .foregroundColor(ColorTokens.shade100)
                                .textStroke(ColorTokens.shade700, lineWidth: 1)
                            
                            Text(timerType.info)
                                .font(.system(size: 16))
                                .foregroundColor(ColorTokens.shade700)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ColorTokens.shade600)
                                .stroke(ColorTokens.shade100, lineWidth: 1)
                                .frame(height: 100)
                                .overlay(
                                    Text("Content for \(timerType.name)")
                                        .font(FontTokens.architectsDaughter(size: 16))
                                        .foregroundColor(ColorTokens.shade100)
                                )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
    }
    
    static var previews: some View {
        SettingTabsPreview.Wrapper()
    }
}
