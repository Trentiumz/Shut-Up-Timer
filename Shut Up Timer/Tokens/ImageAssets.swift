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
    static let friendCodeStripe = Image("friendcode-stripe-image 102")
    static let friendQRBG = Image("friend-qr-bg-image 93")
    static let madFrames = [
        Image("mad_frame_000"),
        Image("mad_frame_001"),
        Image("mad_frame_002"),
        Image("mad_frame_003")
    ]
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
                      .allowsHitTesting(false)
                      .zIndex(-1)
                  )
                  .rotationEffect(Angle(degrees: 2))
                  .clipped()
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
                            .allowsHitTesting(false)
                            .zIndex(-1)
                    )
                    .clipped()
            }
            .frame(width: oWidth * scaleFactor, height: oHeight * scaleFactor)
            .scaleEffect(scaleFactor)
        }
    }
    
    struct FriendCodeStripe : View {
        private var oWidth: CGFloat = 330;
        private var oHeight: CGFloat = 70;
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
                  .frame(width: 330, height: 70)
                  .background(
                    ImageAssets.friendCodeStripe
                      .resizable()
                      .aspectRatio(contentMode: .fill)
                      .frame(width: 419, height: 90)
                      .clipped()
                      .offset(x: -5, y: -15)
                      .allowsHitTesting(false)
                  )
                  .clipped()
            }
            .frame(width: oWidth * scaleFactor, height: oHeight * scaleFactor)
            .scaleEffect(scaleFactor)
        }
    }
    
    struct FriendQRBackground : View {
        private var oWidth: CGFloat = 300;
        private var oHeight: CGFloat = 340;
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
                  .frame(width: 300, height: 340)
                  .background(
                    ImageAssets.friendQRBG
                      .resizable()
                      .aspectRatio(contentMode: .fill)
                      .frame(width: 430.391357421875, height: 430.3922119140625)
                      .clipped()
                      .allowsHitTesting(false)
                  )
                  .clipped()
            }
            .frame(width: oWidth * scaleFactor, height: oHeight * scaleFactor)
            .scaleEffect(scaleFactor)
        }
    }
    
    struct MadMotherImage : View {
        private var oWidth: CGFloat = 330;
        private var oHeight: CGFloat = 270;
        private var ind : Int;
        var scaleFactor: CGFloat;
        
        init(_ ind: Int, width: CGFloat = .infinity, height: CGFloat = .infinity) {
            self.ind = ind;
            assert(0 <= ind && ind < 4);
            if width == .infinity && height == .infinity {
                scaleFactor = 1;
            } else if height == .infinity {
                scaleFactor = width / oWidth;
            } else if height == .infinity {
                scaleFactor = height / oHeight;
            } else {
                scaleFactor = min(width / oWidth, height / oHeight);
            }
        }
        
        var body : some View {
            Group {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 330, height: 270)
                    .background(
                        ImageAssets.madFrames[ind]
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 462, height: 450)
                            .allowsHitTesting(false)
                            .offset(y: 10)
                            .clipped()
                    )
                    .clipped()
            }
            .frame(width: oWidth * scaleFactor, height: oHeight * scaleFactor)
            .scaleEffect(scaleFactor)
        }
    }
    
    struct AnimatedMadMother : View {
        var timeDis : TimeInterval;
        
        @State private var animationPhase : Int = 0;
        @State private var timer: Timer? = nil;
        private var width: CGFloat;
        
        init(width: CGFloat, _ timeDis: TimeInterval = 0.2) {
            self.width = width;
            self.timeDis = timeDis;
        }
        
        var body : some View {
            MadMotherImage(animationPhase, width: width)
                .onAppear {
                    timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                        DispatchQueue.main.async {
                            animationPhase = (self.animationPhase + 1) % 4;
                        }
                    }
                }
                .onDisappear {
                    self.timer?.invalidate()
                    self.timer = nil
                }
        }
    }
}

#Preview {
    FormattedImages.AnimatedMadMother(width: 300)
}
