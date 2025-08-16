import Foundation
import SwiftUI
import Combine
import ActivityKit

// MARK: - LiveActivitySession Enum
enum LiveActivitySession: Codable, Equatable {
    case disabled
    case countdown(startTime: Date, duration: TimeInterval, sentAmber: Bool)
}

// MARK: - LiveActivitySessionWrapper
class LiveActivitySessionWrapper: ObservableObject, Codable, Equatable {
    static let shared = LiveActivitySessionWrapper()
    
    @Published var currentSession: LiveActivitySession {
        didSet {
            saveSession()
        }
    }
    
    private let userDefaultsKey = "live-activity-session"
    
    private init() {
        // Load session from UserDefaults
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let session = try? JSONDecoder().decode(LiveActivitySession.self, from: data) {
            self.currentSession = session
        } else {
            self.currentSession = .disabled
        }
    }
    
    static func == (l: LiveActivitySessionWrapper, r: LiveActivitySessionWrapper) -> Bool {
        return l.currentSession == r.currentSession
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case currentSession
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentSession = try container.decode(LiveActivitySession.self, forKey: .currentSession)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currentSession, forKey: .currentSession)
    }
    
    // MARK: - Private Methods
    private func saveSession() {
        if let encoded = try? JSONEncoder().encode(currentSession) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
}

class LiveActivitySettings: ObservableObject, Codable, Equatable {
    static let shared = LiveActivitySettings()
    
    @Published private(set) var isEnabled: Bool {
        didSet {
            saveSettings()
        }
    }
    @Published private(set) var durationParameter: TimeInterval {
        didSet {
            saveSettings()
        }
    }
    
    private let userDefaultsKey = "live-activity-settings"
    
    private init() {
        // Load settings from UserDefaults
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let settings = try? JSONDecoder().decode(LiveActivitySettings.self, from: data) {
            self.isEnabled = settings.isEnabled
            self.durationParameter = settings.durationParameter
        } else {
            // Default values
            self.isEnabled = false
            self.durationParameter = 60 * 30 // 30 minutes default
            saveSettings()
        }
    }
    
    static func == (l: LiveActivitySettings, r: LiveActivitySettings) -> Bool {
        return l.isEnabled == r.isEnabled &&
        l.durationParameter == r.durationParameter
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case isEnabled
        case durationParameter
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
        durationParameter = try container.decode(TimeInterval.self, forKey: .durationParameter)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(durationParameter, forKey: .durationParameter)
    }
    
    // MARK: - File-Private Methods
    fileprivate func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }
    
    fileprivate func setDurationParameter(_ duration: TimeInterval) {
        durationParameter = duration
    }
    
    // MARK: - Private Methods
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
}

// MARK: - LiveActivityManager
class LiveActivityManager: ObservableObject {
    @Published var sessionWrapper = LiveActivitySessionWrapper.shared
    @Published var settings = LiveActivitySettings.shared
    private let fastAPIClient: FastAPIClient
    private var cancellables: Set<AnyCancellable> = []
    
    // Alternative initializer for testing or custom client setup
    init(fastAPIClient: FastAPIClient) {
        self.fastAPIClient = fastAPIClient
        // Forward nested object changes so SwiftUI refreshes when settings/session change
        settings.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        sessionWrapper.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    deinit {
        cancellables.removeAll()
    }
    
    // MARK: - Public Session Management
    func enableLiveActivity() {
        if !settings.isEnabled {
            settings.setEnabled(true)
            sessionWrapper.currentSession = .countdown(startTime: Date(), duration: settings.durationParameter, sentAmber: false)
            Task {
                await _createLiveActivity()
            }
        }
    }
    
    func synchronizeLiveActivity() async {
        switch sessionWrapper.currentSession {
        case .countdown:
            await _createLiveActivity()
        case .disabled:
            await _destroyLiveActivity()
        }
    }
    
    /// creates the live activity instance
    /// Requires the the current session is already set.
    private func _createLiveActivity() async {
        print("Create live activity called: \(sessionWrapper.currentSession)")
        // First, destroy any existing activity to start fresh
        await _destroyLiveActivity()
        
        // Handle different session types
        switch sessionWrapper.currentSession {
        case .countdown(let startTime, let duration, _):
            // Create Live Activity for countdown sessions
            let attributes = Procrastination_Countdown_ActivityAttributes(
                startTime: startTime
            )
            
            let roast = await RoastGenerator.generateLiveActivityRoast()
            
            // Create initial content
            let content = Procrastination_Countdown_ActivityAttributes.ContentState(
                curRoast: roast ?? "Get back to studying!",
                duration: duration
            )
            
            // Start the Live Activity
            do {
                let activity = try Activity.request(
                    attributes: attributes,
                    content: ActivityContent(state: content, staleDate: startTime.addingTimeInterval(duration)),
                    pushType: .token
                )
                print("Live Activity created successfully: \(activity.id)")
            } catch {
                print("Failed to create Live Activity: \(error)")
            }
            
        case .disabled:
            // No Live Activity needed for studying or disabled sessions
            print("No Live Activity needed for current session type")
            return
        }
        
        // Schedule notifications for the current session
        await _clearAndSendNotifSchedule()
    }
    
    /// destroys the live activity instance
    /// Requires the the current session is already set.
    private func _destroyLiveActivity() async {
        print("Destroy live activity called: \(sessionWrapper.currentSession)")
        for activity in Activity<Procrastination_Countdown_ActivityAttributes>.activities {
            // End the Live Activity
            await activity.end(activity.content, dismissalPolicy: .immediate)
            print("Live Activity destroyed successfully")
        }
        
        // Cancel notifications for the current session
        await _clearAndSendNotifSchedule()
    }
    
    /// for the backend push notification scheduling, we clear the notification schedule and then reschedule it for the current session
    /// Requires the the current session is already set.
    func _clearAndSendNotifSchedule() async {
        switch(self.sessionWrapper.currentSession) {
        case .countdown(let startTime, _, _):
            // increments of 30 minutes
            _ = await fastAPIClient.scheduleLiveActivityNotification(timestamp: startTime.addingTimeInterval(60 * 30))
        default:
            _ = await fastAPIClient.cancelLiveActivityNotifications()
        }
    }
    
    func disableLiveActivity() {
        if settings.isEnabled {
            settings.setEnabled(false)
            sessionWrapper.currentSession = .disabled
            Task {
                await _destroyLiveActivity()
            }
        }
    }
    
    func userStartedStudying() {
        sessionWrapper.currentSession = .disabled
        Task {
            await _destroyLiveActivity()
        }
    }
    
    func userFinishedStudying() {
        if settings.isEnabled {
            sessionWrapper.currentSession = .countdown(startTime: Date(), duration: settings.durationParameter, sentAmber: false)
            Task {
                await _createLiveActivity()
            }
        }
    }
    
    func userRequestedTimeChange(newDuration: TimeInterval) {
        // TODO: Handle time change in backend and update Live Activity
        settings.setDurationParameter(newDuration)
        sessionWrapper.currentSession = switch(sessionWrapper.currentSession) {
        case .countdown(let startTime, _, let sentAmber):
                .countdown(startTime: startTime, duration: settings.durationParameter, sentAmber: sentAmber)
        default:
            sessionWrapper.currentSession
        }
        Task {
            var hasActivity: Bool = false
            for activity in Activity<Procrastination_Countdown_ActivityAttributes>.activities {
                let content = Procrastination_Countdown_ActivityAttributes.ContentState(curRoast: activity.content.state.curRoast, duration: settings.durationParameter)
                await activity.update(ActivityContent(state: content, staleDate: nil))
                hasActivity = true
            }
            if !hasActivity {
                await _createLiveActivity()
            } else {
                await _clearAndSendNotifSchedule()
            }
        }
    }
    
    // MARK: - Utility Functions
    func inStudyingSession() -> Bool {
        // if the last update was in the 10 minutes, be lenient and say in timer session
        if let lasUpdateTime = TempSessionLoader.getSession()?.lastUpdate {
            return lasUpdateTime >= Date().addingTimeInterval(-600)
        }
        return false
    }
}
