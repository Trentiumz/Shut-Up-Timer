import SwiftUI
import CoreData

struct GoalRedeemView: View {
    let goal: Goal
    let onRedeem: (Goal) -> Void
    let onCancel: () -> Void
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var maxWidth: CGFloat? = nil
    
    private func formatIQ(_ iq: Double) -> String {
        let integerPart = Int(iq)
        if integerPart >= 100 {
            return "\(integerPart)"
        } else {
            return String(format: "%.1f", iq)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Cancel Button
            HStack {
                Spacer()
                CommonTaskViews.CancelButton(onCancel: onCancel)
            }
            
            HStack {
                // Trophy/Medal Icon
                Image(uiImage: FormattedImages.Image163)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 100, alignment: .trailing)
                    .layoutPriority(-1)
                
                Spacer()
                    .frame(maxWidth: 20)
                
                VStack {
                    // Goal Name
                    Text(goal.goal ?? "Goal")
                        .font(FontTokens.architectsDaughter(size: 24))
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .frame(width: maxWidth)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(ColorTokens.gray500)
                        )
                        .background(WidthMeasurer())
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .layoutPriority(2)
                    
                    Spacer()
                        .frame(maxHeight: 20)
                    
                    // IQ Cost
                    Text("\(formatIQ(goal.lastGoalProgress?.iqCurrent ?? 0)) IQ / \(formatIQ(goal.lastGoalProgress?.iqGoal ?? 0))")
                        .font(FontTokens.architectsDaughter(size: 24))
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .frame(width: maxWidth)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(ColorTokens.gray500)
                        )
                        .background(WidthMeasurer())
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .layoutPriority(2)
                }
            }
            .onPreferenceChange(MaxWidthKey.self) { newMax  in
                maxWidth = newMax
            }
            .layoutPriority(2)
            
            Spacer()
                .frame(maxHeight: 40)
            
            // Redeem Button
            Button(action: {
                onRedeem(goal)
            }) {
                Text("Redeem this goal?")
                    .font(FontTokens.architectsDaughter(size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(ColorTokens.red300)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white, lineWidth: 3)
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(ColorTokens.brown500)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(ColorTokens.shade100, lineWidth: 6)
        )
    }
    
    private struct WidthMeasurer: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear
                    .preference(key: MaxWidthKey.self, value: proxy.size.width)
            }
        }
    }
    
    private struct MaxWidthKey: PreferenceKey {
        static var defaultValue: CGFloat? = nil
        static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
            value = max(value ?? 0, nextValue() ?? 0)
        }
    }
}

struct GoalRedeemPreview: PreviewProvider {
    
    static var previews: some View {
        // Create a mock Goal for preview
        let context = PersistenceController.shared.container.viewContext
        let goal = Goal(context: context)
        goal.goal = "ECO220"
        goal.addProgress(iqCurrent: 0, iqGoal: 20)
        goal.id = UUID()
        
        return ZStack {
            Color.black
            GoalRedeemView(
                goal: goal,
                onRedeem: { _ in },
                onCancel: { }
            )
        }
        .frame(height: 500)
        .environment(\.managedObjectContext, context)
    }
}
