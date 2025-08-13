import ActivityKit
import Foundation


struct Procrastination_Countdown_ActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var curRoast: String
        var duration: TimeInterval
    }

    // Fixed non-changing properties about your activity go here!
    var startTime: Date
}
