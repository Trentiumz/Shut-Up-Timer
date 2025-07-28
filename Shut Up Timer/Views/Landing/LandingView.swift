import SwiftUI

struct LandingView: View {
    
    @State var selectedScreen: LandingScreen = .tasks;
    // we will affect a task view when we select timer, so we keep track of the 'top screen' here
    @State var taskTopScreen: TaskView.TopTaskScreen = .beckon
    var body: some View {
        ZStack {
            Background()
            
            // Top and bottom bars on top
            VStack(spacing: 0) {
                if selectedScreen == .timer {
                    HStack {
                        Button(action: {
                            withAnimation {
                                selectedScreen = .tasks
                                taskTopScreen = .beckon
                            }
                        }) {
                            Circle()
                                .fill(ColorTokens.red300)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .inset(by: 1)
                                        .stroke(.white, lineWidth: 2)
                                )
                                .overlay(
                                    Text("<")
                                        .font(FontTokens.architectsDaughter(size: 24))
                                        .foregroundColor(.white)
                                )
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                } else {
                    TopBarView(selectedScreen: $selectedScreen)
                        .zIndex(5)
                }
                
                // Background content views
                ZStack {
                    TaskView(taskScreen: $taskTopScreen).tag(LandingScreen.tasks)
                        .opacity(selectedScreen == .tasks || selectedScreen == .timer ? 1 : 0)
                        .allowsHitTesting(selectedScreen == .tasks || selectedScreen == .timer)
                        .frame(maxHeight: .infinity)
                
                    SocialMediaView().tag(LandingScreen.posts)
                        .opacity(selectedScreen == .posts ? 1 : 0)
                        .allowsHitTesting(selectedScreen == .posts)
                
                    DisappointmentView().tag(LandingScreen.stats)
                        .opacity(selectedScreen == .stats ? 1 : 0)
                        .allowsHitTesting(selectedScreen == .stats)
                
                    ViewThatFits {
                        AccountView().tag(LandingScreen.settings)
                            .opacity(selectedScreen == .settings ? 1 : 0)
                            .allowsHitTesting(selectedScreen == .settings)
                        AccountView().tag(LandingScreen.settings)
                            .opacity(selectedScreen == .settings ? 1 : 0)
                            .allowsHitTesting(selectedScreen == .settings)
                            .frame(width: 350)
                    }
                }
                
                if selectedScreen == .timer {
                    Group {
                        Text("START THE GRIND")
                            .font(FontTokens.architectsDaughter(size: 24))
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(ColorTokens.red300)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .inset(by: 1)
                                    .stroke(.white, lineWidth: 2)
                            )
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom)
                } else {
                    BottomBarView(selectedScreen: $selectedScreen, onScreenSelected: { screen in
                        taskTopScreen = .timer(todo: nil)
                    })
                    .zIndex(5)
                }
            }
        }
    }
}
