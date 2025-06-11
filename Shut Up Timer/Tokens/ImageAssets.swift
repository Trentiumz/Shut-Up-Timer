import SwiftUI

enum ImageAssets {
    static let onboardingHello65 = Image("onboarding-hello-image 65")
    static let onboardingHello67 = Image("onboarding-hello-image 67")
    static let onboardingHello68 = Image("onboarding-hello-image 68")
    static let onboardingHello70 = Image("onboarding-hello-image 70")
    static let onboardingHello68Big = Image("onboarding-hello-image 68-big")
    static let todoPaper39 = Image("todo-paper-image 39")
    static let panFryFrames = [
        Image("pan-fry-frame-0"),
        Image("pan-fry-frame-1"),
        Image("pan-fry-frame-2"),
        Image("pan-fry-frame-3"),
        Image("pan-fry-frame-4"),
        Image("pan-fry-frame-5"),
    ]
    static let timerSliderLogo = Image("timer-slider-logo")
    static let roastBackground = Image("roast-image 93")
    static let linedImageBackground = Image("leaderboard-paper-image 106")
    static let leaderboardBandage = Image("leaderboard-bandage-image 107")
}

struct FormattedImages {
    struct LinedImageBackground : View {
        private var oWidth: CGFloat = 370;
        private var oHeight: CGFloat = 250;
        var scaleFactor: CGFloat;
        
        init(width: CGFloat = .infinity, height: CGFloat = .infinity) {
            if width == .infinity && height == .infinity {
                scaleFactor = 1;
            } else if height == .infinity {
                scaleFactor = width / oWidth;
            } else if height == .infinity {
                scaleFactor = height / oHeight;
            } else {
                scaleFactor = min(width / oWidth, height / oHeight)
            }
        }
        
        var body : some View {
            Group {
                Rectangle()
                  .foregroundColor(.clear)
                  .frame(width: oWidth, height: oHeight)
                  .background(
                    ImageAssets.linedImageBackground
                      .resizable()
                      .aspectRatio(contentMode: .fill)
                      .frame(width: 380, height: 396.3481140136719, alignment: .top)
                      .clipped()
                      .offset(x: -5, y: -35)
                  )
                  .rotationEffect(Angle(degrees: 2))
            }
            .frame(width: oWidth * scaleFactor, height: oHeight * scaleFactor)
            .scaleEffect(scaleFactor)
        }
    }
    
    struct LeaderboardBandage : View {
        private var oWidth: CGFloat = 155;
        private var oHeight: CGFloat = 45;
        var scaleFactor: CGFloat;
        
        init(width: CGFloat = .infinity, height: CGFloat = .infinity) {
            if width == .infinity && height == .infinity {
                scaleFactor = 1;
            } else if height == .infinity {
                scaleFactor = width / oWidth;
            } else if height == .infinity {
                scaleFactor = height / oHeight;
            } else {
                scaleFactor = min(width / oWidth, height / oHeight)
            }
        }
        
        var body : some View {
            Group {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: oWidth, height: oHeight)
                    .background(
                        ImageAssets.leaderboardBandage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 402, height: 133)
                            .clipped()
                            .offset(y: -47)
                    )
            }
            .frame(width: oWidth * scaleFactor, height: oHeight * scaleFactor)
            .scaleEffect(scaleFactor)
        }
    }
}

#Preview {
    FormattedImages.LeaderboardBandage(width: 300)
}
