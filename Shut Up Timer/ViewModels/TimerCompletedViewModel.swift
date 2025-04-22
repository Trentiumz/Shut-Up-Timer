import SwiftUI;

class TimerCompletedViewModel : ObservableObject, MVVM {
    @Published var totTime: Int = 0;
    
    func reset(totTime: Int) {
        self.totTime = totTime;
    }
    
    func destroy() {
        
    }
}
