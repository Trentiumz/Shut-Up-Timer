import SwiftUI;

struct StatsView : View {
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        ScrollView {
            VStack {
                StatsCalendarView()
                    .padding()
                
                // Middle section with image and achievements
                HStack(spacing: 20) {
                    // Left side - Peculiar Image Button
                    Button(action: {
                        router.toAlbumView()
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
            }
        }
    }
}
