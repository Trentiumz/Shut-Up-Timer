import SwiftUI
import CoreData

struct AchievementsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch all goals
    @FetchRequest(
        entity: Goal.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Goal.order, ascending: true)]
    ) private var allGoals: FetchedResults<Goal>
    
    // Computed properties for progress calculation
    var totalGoals: Int {
        allGoals.count
    }
    
    var redeemedGoals: Int {
        allGoals.filter { $0.redeemed }.count
    }
    
    var redeemedGoalsList: [Goal] {
        allGoals.filter { $0.redeemed }
    }
    
    var body: some View {
        ZStack {
            Background()
            
            VStack(spacing: 20) {
                // Progress Section
                HStack(alignment: .bottom, spacing: 0) {
                    // Character placeholder (will be FormattedImages.Image172)
                    Group {
                        Image(uiImage: FormattedImages.Image172)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 90)
                            .zIndex(2)
                    }
                    .frame(width: 50, alignment: .trailing)
                    .offset(x: 30)
                    
                    // Progress Bar
                    VStack {
                        GeometryReader { geo in
                            ZStack {
                                // Progress Bar
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(ColorTokens.red300)
                                        .frame(height: 40)
                                    
                                    if totalGoals > 0 {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(ColorTokens.red300)
                                            .frame(width: CGFloat(redeemedGoals) / CGFloat(totalGoals) * 200, height: 20)
                                            .animation(.easeInOut(duration: 0.5), value: redeemedGoals)
                                    }
                                }
                                .frame(width: geo.size.width, height: 40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                
                                Text("\(redeemedGoals)/\(totalGoals) Achieved")
                                    .font(FontTokens.architectsDaughter(size: 24))
                                    .foregroundColor(.white)
                            }
                            .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
                        }
                        Spacer()
                            .frame(height: 15)
                    }
                    
                    Spacer()
                }
                .frame(height: 90)
                .padding(.horizontal, 20)
                
                // Achievements Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        ForEach(redeemedGoalsList, id: \.id) { goal in
                            AchievementCard(goal: goal)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .padding(.top, 20)
        }
    }
}

struct AchievementCard: View {
    let goal: Goal
    
    var body: some View {
        ZStack {
            // Background placeholder (will be FormattedImages.Image173)
            Image(uiImage: FormattedImages.Image173)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .overlay (
                    Image(uiImage: FormattedImages.Image163)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                        .offset(x: -10),
                    alignment: .topLeading
                )
                .overlay (
                    VStack(spacing: 8) {
                        // Goal title
                        Text(goal.goal ?? "Unknown Goal")
                            .font(FontTokens.architectsDaughter(size: 16))
                            .minimumScaleFactor(0.7)
                            .foregroundColor(.black)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .padding(.leading, 25)
                        
                        // IQ progress
                        if let lastProgress = goal.lastGoalProgress {
                            Text("IQ Goal: \(Int(lastProgress.iqGoal))")
                                .font(FontTokens.architectsDaughter(size: 16))
                                .minimumScaleFactor(0.7)
                                .lineLimit(2)
                                .foregroundColor(.gray)
                            
                            Text("IQ: \(Int(lastProgress.iqCurrent))")
                                .font(FontTokens.architectsDaughter(size: 16))
                                .minimumScaleFactor(0.7)
                                .lineLimit(2)
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                    }
                        .padding(.top, 48)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 48)
                )
        }
    }
}

#Preview {
    AchievementsView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
