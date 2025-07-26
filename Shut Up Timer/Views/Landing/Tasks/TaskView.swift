import SwiftUI
import CoreData

struct TaskView: View {
    @State private var isAddingGoal = false
    @Environment(\.managedObjectContext) private var viewContext
    
    private let rightwardAnimation = AnyTransition.asymmetric(
        insertion: AnyTransition.move(edge: .trailing),
        removal: AnyTransition.move(edge: .leading)
    )
    
    var body: some View {
        VStack(spacing: 15) {
            if isAddingGoal {
                GoalAddView { temporaryGoal in
                    let success = addGoal(temporaryGoal)
                    if success {
                        withAnimation {
                            isAddingGoal = false
                        }
                    }
                }
                .padding()
                .transition(rightwardAnimation)
            } else {
                TodoBeckonView()
                    .transition(rightwardAnimation)
            }
            TaskListView(onAddGoal: {
                withAnimation {
                    isAddingGoal = true
                }
            })
            .frame(maxHeight: 400)
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .coordinateSpace(name: "todo-card")
    }
    
    private func addGoal(_ temporaryGoal: TemporaryGoal) -> Bool {
        // get the minimum order value
        let fetchRequest = Goal.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        fetchRequest.fetchLimit = 1
        fetchRequest.propertiesToFetch = ["order"]
        fetchRequest.resultType = .managedObjectResultType
        
        do {
            var minVal: Int16 = 0;
            if let result = try viewContext.fetch(fetchRequest).first {
                minVal = result.value(forKey: "order") as? Int16 ?? 0;
            }
            
            viewContext.reset()
            // add the goal
            let goal = Goal(context: viewContext)
            goal.id = UUID()
            goal.created = Date()
            goal.goal = temporaryGoal.name
            goal.iqGoal = temporaryGoal.iqGoal
            goal.iqCurrent = 0.0
            goal.redeemed = false
            goal.color = colorToHexString(temporaryGoal.color)
            goal.order = minVal - 1
            
            try viewContext.save()
            return true;
        } catch {
            print("Failed to fetch min value: \(error)")
            viewContext.reset()
            return false;
        }
    }
}

#Preview {
    TaskView()
        .environmentObject(AppRouter())
        .environmentObject(SettingsLoader.loadSettings())
} 
