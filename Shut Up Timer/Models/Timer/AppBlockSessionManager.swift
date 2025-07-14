import SwiftUI

class AppBlockSessionManager : CurSessionManager {
    var initialParam: TimerParam
    var startTime: Date
    
    @Published var curParam: TimerParam
    @Published var tasks: [TaskLog]
    
    @Published var curTodo: UUID
    @Published var status: SessionStatus
    
    var managerType: TimerManagerType {
        return .appBlock
    }
    
    /// initializes an AppBlock Session Manager
    init(
        initialParam: TimerParam,
        startTime: Date,
        curParam: TimerParam,
        tasks: [TaskLog],
        curTodo: UUID,
        status: SessionStatus
    ) {
        self.initialParam = initialParam
        self.startTime = startTime
        self.curParam = curParam
        self.tasks = tasks
        self.curTodo = curTodo
        self.status = status
    }
    
    // ------------------ STATE UPDATE FUNCTIONS ------------------
    
    /// set paused (if we aren't done)
    func pause() {
        if status == .inProgress {
            tick(phase: .active) // "finish" the preview window
            status = .paused
        }
    }
    
    /// set resumed (if we aren't done)
    func resume() {
        if status == .paused {
            tick(phase: .active) // "finish" the preview window
            status = .inProgress
        }
    }
    
    func failTimer() {
        status = .failed
    }
    
    func succeedTimer() {
        status = .succeeded
    }
    
    /// updates the timer state - no phase checking needed, just keep updating
    func tick(phase: SceneMiniPhase) {
        // don't update if we succeeded or failed
        if status == .succeeded || status == .failed {
            return
        }
        
        if status == .inProgress {
            // For AppBlock, we use a fixed time interval since we don't track lastActiveUpdate
            let timeSince: TimeInterval = 1.0 // 1 second intervals
            
            // update our task logs using extension
            updateTaskLogs(timeSince: timeSince)
            
            // update our current state using extension
            updateCurrentTimeParams(timeSince: timeSince)
            
            // check success condition using extension
            checkSuccessCondition()
        }
    }
    
    func updateCurTodo(curTodo: UUID) {
        self.curTodo = curTodo
    }
    
    func appReopen() {
        // For AppBlock, fail the user instantly when app is reopened
        failTimer()
    }
    
    // ------------------ ON COMPLETION SESSION ------------------
    func getSession(endTime: Date) -> SessionEntry {
        assert(status == .failed || status == .succeeded)
        
        return SessionEntry(tasks: tasks, started: startTime, ended: endTime, timeLocked: initialParam.getTotTime() - curParam.getTotTime(), plannedTime: initialParam.getTotTime(), success: status == .succeeded)
    }
    
    // ------------------ CODING AND DECODING ------------------
    
    enum CodingKeys: String, CodingKey {
        case initialParam, startTime, curParam, tasks, curTodo, status
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        initialParam = try container.decode(TimerParam.self, forKey: .initialParam)
        startTime = try container.decode(Date.self, forKey: .startTime)
        curParam = try container.decode(TimerParam.self, forKey: .curParam)
        tasks = try container.decode([TaskLog].self, forKey: .tasks)
        curTodo = try container.decode(UUID.self, forKey: .curTodo)
        status = try container.decode(SessionStatus.self, forKey: .status)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(initialParam, forKey: .initialParam)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(curParam, forKey: .curParam)
        try container.encode(tasks, forKey: .tasks)
        try container.encode(curTodo, forKey: .curTodo)
        try container.encode(status, forKey: .status)
    }
} 
