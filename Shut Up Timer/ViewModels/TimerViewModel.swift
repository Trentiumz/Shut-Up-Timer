import SwiftUI

// Countdown timer that changes per second. Either manually stop it, or it will stop itself & call onFinish
class TimerViewModel<Manager: CurSessionManager>: ObservableObject, MVVM {
    @Published var curSession: Manager;
    var selectedTodo: UUID {
        didSet {
            curSession.updateCurTodo(curTodo: selectedTodo)
        }
    }
    
    // the timer
    private var timer: Timer? = nil;
    private var curScenePhase: SceneMiniPhase;
    
    init(from: Manager, startPhase: ScenePhase, appReopened: Bool = true) {
        curSession = from;
        curScenePhase = SceneMiniPhase.from(startPhase);
        selectedTodo = from.curTodo;
        
        if appReopened {
            curSession.appReopen();
        }
    }
    
    func updateScenePhase(_ scenePhase: ScenePhase) {
        curScenePhase = SceneMiniPhase.from(scenePhase)
    }
    
    // starts a timer that counts down totTime (if we don't already have one)
    func startSession() {
        if timer == nil {
            curSession.resume();
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.curSession.tick(phase: self.curScenePhase)
                self.saveTempSession();
            }
        }
    }
    
    // stops and destroys the timer
    func stopSession() {
        curSession.pause();
        timer?.invalidate();
        timer = nil;
    }
    
    // destroys the object before dereferencing
    func destroy() {
        curSession.pause();
        timer?.invalidate()
        timer = nil
    }

    func saveTempSession() {
        TempSessionLoader.saveSession(curSession);
    }
}
