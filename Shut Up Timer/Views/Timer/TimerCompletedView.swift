import SwiftUI
import CoreData

struct TimerCompletedView: View {
    @EnvironmentObject var router: AppRouter;
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch active todos using @FetchRequest for automatic updates
    @FetchRequest(
        entity: Todo.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Todo.created, ascending: false)],
        predicate: NSPredicate(format: "active == YES")
    ) private var activeTodos: FetchedResults<Todo>
    
    private var session: TempSession;
    
    init(session: TempSession) {
        self.session = session;
    }
    
    var body: some View {
        ZStack {
            // Background
            Background()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Background overlay with red triangles
            GeometryReader { screen in
                TimerBackgroundOverlay(screen: screen)
            }
            .ignoresSafeArea(.all)
            
            // Main content area
            VStack(spacing: 0) {
                
                // Completed dialog box
                VStack(spacing: 0) {
                    Text("It's time for a picture...")
                        .font(FontTokens.architectsDaughter(size: 28))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    Spacer()
                        .frame(maxHeight: 40)
                    
                    // Data display boxes
                    HStack(spacing: 15) {
                        // Left box - Study time
                        TimerResultBox(
                            mainText: formatStudyTime(),
                            subText: "of study",
                            textColor: ColorTokens.green500
                        )
                        
                        // Right box - IQ change
                        TimerResultBox(
                            mainText: formatIQChange(),
                            subText: "",
                            textColor: ColorTokens.green500
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
                .padding(.top, 40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(ColorTokens.gray800)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 4)
                        )
                )
                .background(
                    Image(uiImage: FormattedImages.Image172)
                        .resizable()
                        .frame(width: 100, height: 130)
                        .offset(x: -20, y: -120)
                    ,
                    alignment: .topLeading
                )
                .overlay(
                    ZStack(alignment: .top) {
                        Image(uiImage: FormattedImages.Image180)
                            .resizable()
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, -10)
                            .frame(height: 100)
                        
                        VStack(spacing: 0) {
                            Text("BARELY")
                                .font(FontTokens.architectsDaughter(size: 16))
                                .foregroundColor(.white)
                            
                            Text("PASSING")
                                .font(FontTokens.architectsDaughter(size: 48))
                                .minimumScaleFactor(0.7)
                                .foregroundColor(.white)
                                .padding(.top, -15)
                        }
                        .frame(height: 60, alignment: .top)
                        .padding(.top, 15)
                    }.offset(y: -70),
                    alignment: .top
                )
                .overlay(
                    Image(uiImage: FormattedImages.Image182)
                        .resizable()
                        .frame(width: 200, height: 110)
                        .offset(x: 15, y: 60)
                    ,
                    alignment: .bottomTrailing
                )
                .padding(.horizontal, 20)
                .padding(.leading, 30)
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    TimerResultButton(text: "Continue", onSelect: {
                        router.toHome()
                    })
                }
            }
            .padding()
        }
    }
    
    // Helper functions
    private func formatStudyTime() -> String {
        let hours = session.timeLocked / 3600
        return String(format: "%.1fhr", hours)
    }
    
    private func formatIQChange() -> String {
        let iqChange = session.iqChange
        if iqChange >= 0 {
            return "+\(String(format: "%.2f", iqChange))Q"
        } else {
            return "\(String(format: "%.2f", iqChange))Q"
        }
    }
}

#Preview {
    TimerCompletedView(session: TempSession(
        tasks: [],
        started: Date(),
        ended: Date(),
        timeLocked: 19100, // ~5.3 hours
        plannedTime: 36000, // 10 hours planned
        success: true,
        roast: nil
    ))
}


