import SwiftUI

// Countdown timer that changes per second. Either manually stop it, or it will stop itself & call onFinish
class TimerViewModel: ObservableObject, MVVM {
    // used to track timer running
    var totTime: Int = 0;
    @Published var timeLeft: Int = 0;
    @Published var isRunning: Bool = false;
    
    // the timer
    private var timer: Timer? = nil;
    
    init() {
        
    }
    
    func reset(totTime: Int) {
        destroy();
        self.totTime = totTime;
        self.timeLeft = totTime;
        self.timer = nil;
        self.isRunning = false;
    }
    
    func startTimer() {
        if(!isRunning) {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if(self.timeLeft <= 0) {
                    self.stopTimer();
                } else {
                    DispatchQueue.main.async {
                        self.timeLeft -= 1;
                    }
                }
            }
            isRunning = true;
        }
    }
    
    func stopTimer() {
        timer?.invalidate();
        isRunning = false;
        timer = nil;
    }
    
    func destroy() {
        timer?.invalidate()
        timer = nil
    }
}
