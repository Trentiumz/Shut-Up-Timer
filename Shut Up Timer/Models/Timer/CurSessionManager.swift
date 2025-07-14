import SwiftUI

protocol CurSessionManager: ObservableObject, Codable {
    var initialParam: TimerParam { get set }
    var startTime: Date { get set }
    var curParam: TimerParam { get set }
    var tasks: [TaskLog] { get set }
    var curTodo: UUID { get set }
    var status: SessionStatus { get set }
    var managerType: TimerManagerType { get }
    
    func pause()
    func resume()
    func tick(phase: SceneMiniPhase)
    func updateCurTodo(curTodo: UUID)
    func failTimer()
    func succeedTimer()
    func getSession(endTime: Date) -> SessionEntry
    func appReopen()
}

// MARK: - CurSessionManager Extensions
extension CurSessionManager {
    /// Updates task logs with the given time since last update
    func updateTaskLogs(timeSince: TimeInterval) {
        guard status == .inProgress else {
            print("ERROR: Cannot update task logs when status is not inProgress, current status: \(status)")
            return
        }
        
        if tasks.isEmpty || tasks.last!.todoID != curTodo {
            tasks.append(TaskLog(todoID: curTodo, timeIn: timeSince))
        } else {
            tasks[tasks.count - 1].timeIn += timeSince
        }
    }
    
    /// Updates the current parameter by subtracting the given time
    func updateCurrentTimeParams(timeSince: TimeInterval) {
        guard status == .inProgress else {
            print("ERROR: Cannot update current state when status is not inProgress, current status: \(status)")
            return
        }
        
        curParam = switch(curParam) {
        case .countdown(let seconds):
                .countdown(seconds: seconds - timeSince)
        }
    }
    
    /// Checks success condition and succeeds timer if conditions are met
    func checkSuccessCondition() {
        guard status == .inProgress else {
            print("ERROR: Cannot check success condition when status is not inProgress, current status: \(status)")
            return
        }
        
        switch(curParam) {
        case .countdown(let seconds):
            if seconds <= 0 {
                succeedTimer()
            }
        }
    }
}
