import SwiftUI
import FamilyControls
import ManagedSettings

enum SessionStatus : Codable {
    case inProgress;
    case paused;
    case succeeded;
    case failed;
}

enum SceneMiniPhase : Codable {
    case active;
    case inactive;
    
    static func from(_ phase: ScenePhase) -> SceneMiniPhase {
        return switch(phase) {
        case .active:
                .active;
        default:
                .inactive;
        }
    }
}

class NoLeaveSessionManager : CurSessionManager {
    var initialParam: TimerParam;
    var startTime: Date;
    
    @Published var curParam: TimerParam;
    @Published var tasks: [TaskLog];
    
    var lastActiveUpdate: Date;
    
    @Published var curTodo: UUID;
    @Published var status: SessionStatus;
    
    // App blocker instance for managing app blocking functionality
    private var appBlocker: AppBlocker?
    
    var managerType: TimerManagerType {
        return .noLeave
    }
    
    /// initializes a Session in Progeress
    init(
        initialParam: TimerParam,
        startTime: Date,
        curParam: TimerParam,
        tasks: [TaskLog],
        lastActiveUpdate: Date,
        curTodo: UUID,
        status: SessionStatus
    ) {
        self.initialParam = initialParam
        self.startTime = startTime
        self.curParam = curParam
        self.tasks = tasks
        self.lastActiveUpdate = lastActiveUpdate
        self.curTodo = curTodo
        self.status = status
        
        // Initialize the app blocker with failTimer closure
        self.appBlocker = AppBlocker(failTimer: { [weak self] in
            self?.failTimer()
        })
        
        // If we're already in progress (e.g., restoring from saved session), start blocking immediately
        if status == .inProgress {
            appBlocker?.startBlocking()
        }
    }
    
    deinit {
        // Clean up resources when session manager is destroyed
        appBlocker?.destroy()
    }
    
    // ------------------ STATE UPDATE FUNCTIONS ------------------
    
    /// set paused (if we aren't done)
    func pause() {
        if status == .inProgress {
            tick(phase: .active) // "finish" the preview window
            status = .paused;
            appBlocker?.stopBlocking()
        }
    }
    
    /// set resumed (if we aren't done)
    func resume() {
        if status == .paused {
            tick(phase: .active); // "finish" the preview window
            status = .inProgress;
            appBlocker?.startBlocking()
        }
    }
    
    func failTimer() {
        status = .failed;
        appBlocker?.stopBlocking()
    }
    func succeedTimer() {
        status = .succeeded;
        appBlocker?.stopBlocking()
    }
    
    /// updates the scene phase given an update of the timer
    func tick(phase: SceneMiniPhase) {
        // don't update if we succeeded or failed, and for now, only 'update' on active
        if status == .succeeded || status == .failed {
            return;
        }
        if phase != .active {
            return;
        }
        
        let curTime = Date()
        
        if status == .inProgress {
            if curTime.timeIntervalSince(lastActiveUpdate) > 30 {
                failTimer()
                return;
            }
            
            // update our task logs using extension
            let timeSince = curTime.timeIntervalSince(lastActiveUpdate);
            updateTaskLogs(timeSince: timeSince)
            
            // update our current state using extension
            updateCurrentTimeParams(timeSince: timeSince)
            
            // check success condition using extension
            checkSuccessCondition()
        }
        
        // update our last active update variable
        if phase == .active {
            lastActiveUpdate = curTime
        }
    }
    
    func updateCurTodo(curTodo: UUID) {
        self.curTodo = curTodo;
    }
    
    func appReopen() {
        // Method to handle updating session variables when app is closed and reopened
        // Currently does nothing
    }
    
    func destroy() {
        // Clean up resources when session is being destroyed
        appBlocker?.destroy()
    }
    
    // ------------------ ON COMPLETION SESSION ------------------
    func getSession(endTime: Date) -> SessionEntry {
        assert(status == .failed || status == .succeeded);
        
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
        lastActiveUpdate = try container.decode(Date.self, forKey: .lastActiveUpdate)
        curTodo = try container.decode(UUID.self, forKey: .curTodo)
        status = try container.decode(SessionStatus.self, forKey: .status)
        
        // Initialize the app blocker with failTimer closure
        self.appBlocker = AppBlocker(failTimer: { [weak self] in
            self?.failTimer()
        })
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(initialParam, forKey: .initialParam)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(curParam, forKey: .curParam)
        try container.encode(tasks, forKey: .tasks)
        try container.encode(lastActiveUpdate, forKey: .lastActiveUpdate)
        try container.encode(curTodo, forKey: .curTodo)
        try container.encode(status, forKey: .status)
    }
}
