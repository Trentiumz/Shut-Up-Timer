import SwiftUI
import CoreData

struct TemporaryTask {
    var listID: UUID = UUID()
    var goal: Goal?
    var name: String = ""
}

struct TaskAddView: View {
    @State private var tasks: [TemporaryTask] = [TemporaryTask()]
    @Environment(\.managedObjectContext) private var viewContext
    let onTaskAdd: ([TemporaryTask]) -> Void
    let onCancel: () -> Void
    
    // Fetch available goals
    @FetchRequest(
        entity: Goal.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Goal.order, ascending: true),
                          NSSortDescriptor(keyPath: \Goal.created, ascending: false)],
        predicate: NSPredicate(format: "redeemedAt == nil")
    ) private var goals: FetchedResults<Goal>
    
    var body: some View {
        DarkContentContainer {
            VStack {
                // Header
                Text("Add Tasks")
                    .font(FontTokens.architectsDaughter(size: 24))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // ScrollView with tasks
                List {
                    ForEach(Array(tasks.enumerated()), id: \.element.listID) { index, task in
                        TaskMakeView(
                            task: $tasks[index],
                            availableGoals: Array(goals),
                            onUserInteract: {
                                onUserInteract(at: index)
                            }
                        )
                        .opacity(index == tasks.count - 1 ? 0.7 : 1)
                        .padding(.bottom, 8)
                        .swipeActions(edge: .leading) {
                            if index != tasks.count - 1 {
                                Button(role: .destructive) {
                                    tasks.remove(at: index)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            if index != tasks.count - 1 {
                                Button(role: .destructive) {
                                    tasks.remove(at: index)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.horizontal)
                
                // Add Tasks button
                Button(action: {
                    onTaskAdd(Array(tasks.dropLast()))
                }) {
                    Text("Add Tasks")
                        .font(FontTokens.architectsDaughter(size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ColorTokens.red300)
                        )
                }
                .disabled(tasks.count <= 1)
                .opacity(tasks.count <= 1 ? 0.5 : 1.0)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .overlay(
            VStack {
                HStack {
                    Spacer()
                    CommonTaskViews.CancelButton(onCancel: onCancel)
                }
                Spacer()
            }
                .padding(.trailing, 8)
        )
    }
    
    private func onUserInteract(at index: Int) {
        // If this is the last task and it now has content, add a new empty task
        if index == tasks.count - 1 {
            tasks.append(TemporaryTask())
        }
    }
}

// MARK: - TaskMakeView Component
fileprivate struct TaskMakeView: View {
    @Binding var task: TemporaryTask
    let availableGoals: [Goal]
    let onUserInteract: () -> Void
    
    @State private var showingGoalPicker = false
    
    func getGoalColor(_ goalColor: String?) -> Color {
        if let goalColor = goalColor {
            return hexStringToColor(goalColor)
        } else {
            return ColorTokens.red300
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Goal Selector on the left
            Button(action: {
                showingGoalPicker = true
                onUserInteract()
            }) {
                if let goal = task.goal {
                    ZStack {
                        Rectangle()
                            .fill(getGoalColor(goal.color))
                            .frame(width: 60, height: 40)
                            .cornerRadius(8)
                        
                        Text(goal.goal ?? "Goal")
                            .font(FontTokens.architectsDaughter(size: 16))
                            .foregroundColor(goodOverlayColor(for: getGoalColor(goal.color)))
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                            .frame(maxWidth: 60)
                    }
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(ColorTokens.red300)
                            .frame(width: 60, height: 40)
                        
                        Text("None")
                            .font(FontTokens.architectsDaughter(size: 16))
                            .foregroundColor(goodOverlayColor(for: ColorTokens.red300))
                            .minimumScaleFactor(0.5)
                            .frame(maxWidth: 60)
                    }
                }
            }
            .buttonStyle(.plain)
            .frame(width: 70)
            
            // Task name TextField on the right
            TextField("Enter task name", text: Binding(
                get: { task.name },
                set: { newValue in
                    task.name = newValue
                    onUserInteract()
                }
            ))
            .font(FontTokens.architectsDaughter(size: 16))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .overlay (
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
            )
        }
        .confirmationDialog("Select Goal", isPresented: $showingGoalPicker, titleVisibility: .visible) {
            Button("None") {
                task.goal = nil
            }
            
            ForEach(availableGoals, id: \.id) { goal in
                Button(goal.goal ?? "Unknown Goal") {
                    task.goal = goal
                }
            }
            
            Button("Cancel", role: .cancel) { }
        }
    }
}

func goodOverlayColor(for color: Color) -> Color {
    // Convert to UIColor to extract components
    let uiColor = UIColor(color)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0

    uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

    // Calculate luminance using sRGB luminance formula
    // https://en.wikipedia.org/wiki/Relative_luminance
    let luminance = 0.299 * red + 0.587 * green + 0.114 * blue

    // If luminance is dark, return white overlay; else black
    return luminance < 0.5 ? Color.white : Color.black
}

#Preview {
    ZStack {
        Color.black
        TaskAddView { _ in
            // Preview handler
        } onCancel: {
            
        }
        .frame(height: 300)
    }
    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
