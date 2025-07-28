import SwiftUI

struct TimerPreStartSelector: View {
    let todo: Todo?
    
    var body: some View {
        VStack {
            LandingTimerSelectorView()
            let taskToDisplay = todo != nil ? "Selected Task: \(todo!.todo ?? "Unknown")" : "No task selected"
            Text(taskToDisplay)
                .font(FontTokens.architectsDaughter(size: 16))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}
