import SwiftUI

protocol CurSessionManager: ObservableObject, Codable {
    var initialParam: TimerParam { get set }
    var startTime: Date { get set }
    var curParam: TimerParam { get set }
    var tasks: [TempTaskLog] { get set }
    var curTodo: UUID { get set }
    var status: SessionStatus { get set }
    var managerType: TimerManagerType { get }
    var lastUpdate: Date { get }
    
    func pause()
    func resume()
    /// updates the state of the current session manager; the phase should be the phase of the most recent window, as should the status
    func tick(phase: SceneMiniPhase)
    func updateCurTodo(curTodo: UUID)
    func failTimer()
    func succeedTimer()
    func getSession(endTime: Date) -> TempSession
    func appReopen()
    func destroy()
}

// MARK: - CurSessionManager Extensions
extension CurSessionManager {
    /// Updates task logs with the given time since last update
    fileprivate func updateTaskLogs(timeSince: TimeInterval) {
        guard status == .inProgress else {
            print("ERROR: Cannot update task logs when status is not inProgress, current status: \(status)")
            return
        }
        
        if tasks.isEmpty || tasks.last!.todoID != curTodo {
            tasks.append(TempTaskLog(todoID: curTodo, timeIn: timeSince))
        } else {
            tasks[tasks.count - 1].timeIn += timeSince
        }
    }
    
    /// Updates the current parameter by subtracting the given time
    fileprivate func updateCurrentTimeParams(timeSince: TimeInterval) {
        guard status == .inProgress else {
            print("ERROR: Cannot update current state when status is not inProgress, current status: \(status)")
            return
        }
        
        curParam = curParam.update(timeSince: timeSince)
    }
    
    /// Checks success condition and succeeds timer if conditions are met
    fileprivate func checkSuccessCondition() {
        guard status == .inProgress else {
            print("ERROR: Cannot check success condition when status is not inProgress, current status: \(status)")
            return
        }
        
        switch(curParam) {
        case .countdown(let seconds):
            if seconds <= 0 {
                succeedTimer()
            }
        case .stopwatch(_):
            break
        case .pomodoro(_):
            break
        }
    }
    
    /// updates the session information given the time interval since the last "active" update, 
    func updateSessionInfo(timeSince: TimeInterval) {
        let isWorking = switch(curParam) {
        case .countdown(_):
            true
        case .stopwatch(_):
            true
        case .pomodoro(let pomo):
            switch(pomo.progress) {
            case .inSession(_):
                true
            case .onBreak(_):
                false
            }
        }
        if isWorking {
            updateTaskLogs(timeSince: timeSince)
        }
        
        // update our current state using extension
        updateCurrentTimeParams(timeSince: timeSince)
        
        switch(curParam) {
        case .pomodoro(let pomo):
            switch pomo.progress{
            case .inSession(let left):
                if left <= 0 {
                    curParam = .pomodoro(pomo: TimerParam.Pomodoro(progress: .onBreak(left: pomo.breakTime), timeLocked: pomo.timeLocked, sessionTime: pomo.sessionTime, breakTime: pomo.breakTime))
                }
            default:
                break
            }
        default:
            break
        }
        
        // check success condition using extension
        checkSuccessCondition()
    }
    
    var iqChange: Double {
        let plannedTime: TimeInterval = initialParam.getTimeRemaining()
        let timeLeft: TimeInterval = curParam.getTimeRemaining()
        let timeLocked = plannedTime - timeLeft
        return Session.getIQChange(lockedTime: timeLocked, success: true)
    }
}
