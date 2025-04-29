import SwiftUI

// Countdown timer that changes per second. Either manually stop it, or it will stop itself & call onFinish
class TimerViewModel: ObservableObject, MVVM {
    // used to track timer running
    var totTime: Int = 0;
    var startTime: Date = Date();
    var todoID: UUID = UUID();
    @Published var timeLeft: Int = 0;
    @Published var isRunning: Bool = false;
    
    // the timer
    private var timer: Timer? = nil;
    
    init() {
        
    }
    
    // resets the model to its initial state
    func reset(totTime: Int, startTime: Date, todoID: UUID) {
        destroy();
        self.totTime = totTime;
        self.startTime = startTime;
        self.todoID = todoID;
        self.timeLeft = totTime;
        self.timer = nil;
        self.isRunning = false;
    }
    
    // starts a timer that counts down totTime
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
    
    // stops and destroys the timer
    func stopTimer() {
        timer?.invalidate();
        isRunning = false;
        timer = nil;
    }
    
    // destroys the object before dereferencing
    func destroy() {
        timer?.invalidate()
        timer = nil
    }
}
