import SwiftUI

// Countdown timer that changes per second. Either manually stop it, or it will stop itself & call onFinish
class TimerViewModel: ObservableObject {
    // used to track timer running
    var totTime: Int;
    @Published var timeLeft: Int;
    @Published var isRunning: Bool;
    
    // the timer
    private var timer: Timer?;
    
    init(totTime: Int) {
        self.totTime = totTime;
        self.timeLeft = totTime;
        self.timer = nil;
        self.isRunning = false;
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if(self.timeLeft <= 0) {
                self.stopTimer();
            } else {
                self.timeLeft -= 1;
            }
        }
        isRunning = true;
    }
    
    func stopTimer() {
        timer?.invalidate();
        isRunning = false;
        timer = nil;
    }
    
    func destroy() {
        timer?.invalidate();
        timer = nil;
    }
}
