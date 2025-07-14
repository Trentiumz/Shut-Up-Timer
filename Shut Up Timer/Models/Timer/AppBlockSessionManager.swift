import SwiftUI
import FamilyControls
import ManagedSettings

class AppBlockSessionManager : CurSessionManager {
    var initialParam: TimerParam
    var startTime: Date
    
    @Published var curParam: TimerParam
    @Published var tasks: [TaskLog]
    
    var lastUpdate: Date
    
    @Published var curTodo: UUID
    @Published var status: SessionStatus
    
    // ManagedSettings store for app blocking
    private let store = ManagedSettingsStore()
    
    // Timer for checking permissions
    private var permissionTimer: Timer?
    
    var managerType: TimerManagerType {
        return .appBlock
    }
    
    /// initializes an AppBlock Session Manager
    init(
        initialParam: TimerParam,
        startTime: Date,
        curParam: TimerParam,
        tasks: [TaskLog],
        lastUpdate: Date,
        curTodo: UUID,
        status: SessionStatus
    ) {
        self.initialParam = initialParam
        self.startTime = startTime
        self.curParam = curParam
        self.tasks = tasks
        self.lastUpdate = lastUpdate
        self.curTodo = curTodo
        self.status = status
        
        // If we're already in progress (e.g., restoring from saved session), start blocking immediately
        if status == .inProgress {
            // Check permissions first
            if checkPermissions() {
                startBlocking()
                startPermissionTimer()
            } else {
                // Can't start blocking without permissions, fail immediately
                self.status = .failed
            }
        }
    }
    
    deinit {
        // Clean up resources when session manager is destroyed
        stopBlocking()
        stopPermissionTimer()
    }
    
    // MARK: - App Blocking Functions
    
    /// Starts blocking apps using the settings
    private func startBlocking() {
        // Get the current settings
        let settings = SettingsLoader.loadSettings()
        
        // Block the selected apps
        store.shield.applications = settings.defaultBlockedApps.applicationTokens
        store.shield.applicationCategories = .specific(settings.defaultBlockedApps.categoryTokens)
        
        print("Started blocking apps: \(settings.defaultBlockedApps.applicationTokens.count) apps, \(settings.defaultBlockedApps.categoryTokens.count) categories")
    }
    
    /// Stops blocking apps
    private func stopBlocking() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        
        print("Stopped blocking apps")
    }
    
    /// Checks if FamilyControls permissions are still granted
    private func checkPermissions() -> Bool {
        let authStatus = FamilyControls.AuthorizationCenter.shared.authorizationStatus
        return authStatus == .approved
    }
    
    /// Starts the permission checking timer
    private func startPermissionTimer() {
        permissionTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            if !self.checkPermissions() {
                print("FamilyControls permissions revoked, failing timer")
                self.failTimer()
            }
        }
    }
    
    /// Stops the permission checking timer
    private func stopPermissionTimer() {
        permissionTimer?.invalidate()
        permissionTimer = nil
    }
    
    // ------------------ STATE UPDATE FUNCTIONS ------------------
    
    /// set paused (if we aren't done)
    func pause() {
        if status == .inProgress {
            tick(phase: .active) // "finish" the preview window
            status = .paused
            stopBlocking()
            stopPermissionTimer()
        }
    }
    
    /// set resumed (if we aren't done)
    func resume() {
        if status == .paused {
            tick(phase: .active) // "finish" the preview window
            status = .inProgress
            
            // Check permissions before starting
            if !checkPermissions() {
                failTimer()
                return
            }
            
            startBlocking()
            startPermissionTimer()
        }
    }
    
    func failTimer() {
        status = .failed
        stopBlocking()
        stopPermissionTimer()
    }
    
    func succeedTimer() {
        status = .succeeded
        stopBlocking()
        stopPermissionTimer()
    }
    
    /// updates the timer state - uses lastActiveUpdate to track time like NoLeaveSessionManager
    func tick(phase: SceneMiniPhase) {
        // don't update if we succeeded or failed, and for now, only 'update' on active
        if status == .succeeded || status == .failed {
            return
        }
        
        let curTime = Date()
        
        if status == .inProgress {
            // update our task logs using extension
            let timeSince = curTime.timeIntervalSince(lastUpdate)
            updateTaskLogs(timeSince: timeSince)
            
            // update our current state using extension
            updateCurrentTimeParams(timeSince: timeSince)
            
            // check success condition using extension
            checkSuccessCondition()
            
            self.lastUpdate = curTime
        }
    }
    
    func updateCurTodo(curTodo: UUID) {
        self.curTodo = curTodo
    }
    
    func appReopen() {
        // For AppBlock, fail the user instantly when app is reopened
        failTimer()
    }
    
    func destroy() {
        // Clean up resources when session is being destroyed
        stopBlocking()
        stopPermissionTimer()
    }
    
    // ------------------ ON COMPLETION SESSION ------------------
    func getSession(endTime: Date) -> SessionEntry {
        assert(status == .failed || status == .succeeded)
        
        return SessionEntry(tasks: tasks, started: startTime, ended: endTime, timeLocked: initialParam.getTotTime() - curParam.getTotTime(), plannedTime: initialParam.getTotTime(), success: status == .succeeded)
    }
    
    // ------------------ CODING AND DECODING ------------------
    
    enum CodingKeys: String, CodingKey {
        case initialParam, startTime, curParam, tasks, lastActiveUpdate, curTodo, status
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        initialParam = try container.decode(TimerParam.self, forKey: .initialParam)
        startTime = try container.decode(Date.self, forKey: .startTime)
        curParam = try container.decode(TimerParam.self, forKey: .curParam)
        tasks = try container.decode([TaskLog].self, forKey: .tasks)
        lastUpdate = try container.decode(Date.self, forKey: .lastActiveUpdate)
        curTodo = try container.decode(UUID.self, forKey: .curTodo)
        status = try container.decode(SessionStatus.self, forKey: .status)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(initialParam, forKey: .initialParam)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(curParam, forKey: .curParam)
        try container.encode(tasks, forKey: .tasks)
        try container.encode(lastUpdate, forKey: .lastActiveUpdate)
        try container.encode(curTodo, forKey: .curTodo)
        try container.encode(status, forKey: .status)
    }
} 
