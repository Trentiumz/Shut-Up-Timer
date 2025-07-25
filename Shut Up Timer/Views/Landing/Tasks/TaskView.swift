import SwiftUI

struct TaskView: View {
    
    var body: some View {
        VStack(spacing: 15) {
            TodoBeckonView()
            TaskListView()
                .frame(maxHeight: 400)
                .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .coordinateSpace(name: "todo-card")
    }
}

#Preview {
    TaskView()
        .environmentObject(AppRouter())
        .environmentObject(SettingsLoader.loadSettings())
} 
