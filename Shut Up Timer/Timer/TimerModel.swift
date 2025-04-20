import SwiftUI

// Countdown timer that changes per second. Either manually stop it, or it will stop itself & call onFinish
class TimerViewModel: ObservableObject {
    // used to track timer running
    var totTime: Int;
    @Published var timeLeft: Int;
    @Published var timerRunning: Bool;
    var onFinish: () -> Void;
    
    // private state to make sure a stopped timer isn't fired again
    private var isStopped: Bool;
    
    // the timer
    private var timer: Timer?;
    
    private static let defaultCallback: () -> Void = {}
    
    init(onFinish: @escaping (() -> Void) = defaultCallback, totTime: Int = 1800) {
        self.totTime = totTime;
        self.timeLeft = totTime;
        self.onFinish = onFinish;
        self.timerRunning = false;
        self.isStopped = false;
        
        // Start the timer that updates every second
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.checkTimerStatus();
            if self.timerRunning {
                if(self.timeLeft <= 0) {
                    self.onFinish();
                    self.stopTimer();
                } else {
                    self.timeLeft -= 1;
                }
            }
        }
    }
    
    // asserts the Timer isn't being used right now
    func checkTimerStatus() {
        guard !isStopped else {
            preconditionFailure("Timer has already been stopped");
        }
    }
    
    func startTimer() {
        checkTimerStatus();
        self.timerRunning = true
    }
    
    func pauseTimer() {
        checkTimerStatus();
        self.timerRunning = false
    }
    
    func stopTimer() {
        checkTimerStatus();
        
        timerRunning = false;
        timer?.invalidate();
        timer = nil;
        timeLeft = 0;
        self.isStopped = true;
    }
}
