import SwiftUI;

struct OnboardingInfo1 : View {
    let onPress: () -> Void
    let onPrevious: () -> Void
    
    var body : some View {
        ZStack {
            Background()
            ScrollView {
                VStack(alignment: .leading) {
                    BackButton(onPress: onPrevious)
                    Spacer()
                    Rectangle()
                        .foregroundStyle(.clear)
                        .frame(height: 80)
                        .allowsHitTesting(false)
                    VStack(spacing: 50) {
                        ZStack(alignment: .topTrailing) {
                            ZStack {
                                Rectangle()
                                  .foregroundColor(.clear)
                                  .frame(width: 400, height: 400)
                                  .background(
                                    ImageAssets.onboardingHello68
                                      .resizable()
                                      .aspectRatio(contentMode: .fill)
                                      .frame(width: 643, height: 500)
                                      .offset(x: -70, y: -50)
                                      .allowsHitTesting(false),
                                    alignment: .leading
                                  )
                                  .allowsHitTesting(false)
                                VStack {
                                    Text("Use this app for one month and maybe you'll finally:")
                                      .font(Font.custom("ArchitectsDaughter-Regular", size: 25))
                                      .multilineTextAlignment(.center)
                                      .foregroundColor(ColorTokens.shade700)
                                      .frame(width: 340.67834, alignment: .top)
                                    Text("📖 Focus like someone who actually wants to pass\n\n📵 Touch your phone less than your fridge door\n\n🧠 Train that brain of yours - not just your TikTok reflexes")
                                      .font(Font.custom("ArchitectsDaughter-Regular", size: 20))
                                      .foregroundColor(ColorTokens.shade700)
                                      .frame(width: 301.62216, alignment: .topLeading)
                                      
                                }.rotationEffect(Angle(degrees: -1.5))
                            }
                            Rectangle()
                              .foregroundColor(.clear)
                              .frame(width: 197, height: 197)
                              .background(
                                ImageAssets.onboardingHello65
                                  .resizable()
                                  .aspectRatio(contentMode: .fill)
                                  .frame(width: 197, height: 197)
                                  .clipped()
                              )
                              .offset(x: 30, y: -110)
                        }
                        Spacer()
                        OnboardingNextButton(text: "Make mother proud for once!", onSelect: onPress)
                            .padding()
                        Spacer()
                    }
                }
                .frame(minHeight: UIScreen.main.bounds.height)
            }
            .padding(.top)
            .frame(maxHeight: UIScreen.main.bounds.height)
        }
    }
}

#Preview {
    OnboardingInfo1(onPress: {}, onPrevious: { print("Back") })
}
