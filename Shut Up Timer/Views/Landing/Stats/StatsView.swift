import SwiftUI;

struct StatsView : View {
    @EnvironmentObject var router: AppRouter
    enum StatDisplay {
        case stats
        case album
    }
    @Binding var statDisplay: StatDisplay
    
    var body: some View {
        ScrollView {
            VStack {
                StatsCalendarView()
                    .padding()
                
                switch(statDisplay) {
                case .stats:
                    // Middle section with image and achievements
                    HStack(spacing: 20) {
                        // Left side - Peculiar Image Button
                        Button(action: {
                            withAnimation {
                                statDisplay = .album
                            }
                        }) {
                            AlbumViewButtonIcon()
                                .padding(12)
                        }
                        
                        Spacer()
                        
                        // Right side - Achievements (placeholder for now)
                        Button(action: {
                            router.toAchievementsView()
                        }) {
                            FormattedImages.DisappointmentBook("Achievements", width: 150)
                        }
                    }
                    .padding(.horizontal, 25)
                    StatsSummaryView()
                        .frame(maxHeight: 300, alignment: .top)
                        .padding()
                case .album:
                    AlbumView()
                        .padding()
                }
            }
        }
    }
}
