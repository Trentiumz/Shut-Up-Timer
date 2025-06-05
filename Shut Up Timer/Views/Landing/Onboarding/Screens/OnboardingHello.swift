import SwiftUI

struct OnboardingHello: View {
    let infoText: String
    let buttonText: String
    let onPress: () -> Void
    let onPrevious: (() -> Void)?
    
    var body: some View {
        ZStack {
            Rectangle()
              .foregroundColor(.clear)
              .background(
                ImageAssets.onboardingHello67
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .clipped()
              )
              .edgesIgnoringSafeArea(.all)
            GeometryReader { geo in
                VStack(spacing: 0) {
                    Spacer()
                    ZStack {
                        ImageAssets.onboardingHello68
                            .foregroundColor(.clear)
                            .frame(width: 374, height: 374)
                        Text(infoText)
                            .font(Font.custom("ArchitectsDaughter-Regular", size: 30))
                            .multilineTextAlignment(.center)
                            .foregroundColor(ColorTokens.shade700)
                            .frame(width: 292, alignment: .top)
                            .rotationEffect(Angle(degrees: -2))
                            .offset(x: 0, y: 20)
                        ImageAssets.onboardingHello65
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 197, height: 197)
                            .clipped()
                            .offset(x: 110, y: -120)
                    }
                    Spacer()
                    
                    VStack {
                        Text(buttonText)
                          .font(Font.custom("ArchitectsDaughter-Regular", size: 30))
                          .foregroundColor(ColorTokens.shade100)
                          .frame(alignment: .topLeading)
                          .background(
                            Button(action: {
                                self.onPress()
                            }){
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 328, height: 74)
                                    .background(ColorTokens.red300)
                                    .cornerRadius(30)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .inset(by: 1)
                                            .stroke(ColorTokens.shade700, lineWidth: 2)
                                    )
                            }
                          )
                        Spacer()
                    }
                    .frame(height: geo.size.height / 4)
                }.frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if let onPrevious = self.onPrevious {
                ZStack {
                    HStack {
                        VStack {
                            Button(action: {
                                onPrevious()
                            }) {
                                Text("←")
                                  .font(Font.custom("ArchitectsDaughter-Regular", size: 40))
                                  .foregroundColor(ColorTokens.shade700)
                                  .clipped()
                            }.padding()
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(ColorTokens.shade300)
    }
}

#Preview {
    OnboardingHello(infoText: "Testing text!", buttonText: "Hello", onPress: {}, onPrevious: {print("Previous")})
}
