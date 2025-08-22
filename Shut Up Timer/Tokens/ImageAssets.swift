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
    static let disappointmentBook = Image("leaderboard-book-image 120")
    static let disappointmentStrip = Image("leaderboard-strip-image 122")
    static let disappointmentChevron = Image("DisappointmentChevron-Polygon 1")
    static let feedbackUpvoteButton = Image("feedback-upvote-image 140")
    static let postBoundPage = Image("post-boundpage-image 0 12")
    
    // New images
    static let image153 = UIImage(named: "image 153")!
    static let image146 = UIImage(named: "image 146")!
    static let image147 = UIImage(named: "image 147")!
    static let image124 = UIImage(named: "image 124")!
    static let image144 = UIImage(named: "image 144")!
    static let image145 = UIImage(named: "image 145")!
    static let image161 = UIImage(named: "image 161")!
    static let qrCode2 = UIImage(named: "qr-code 2")!
    static let image164 = UIImage(named: "image 164")!
    static let image166 = UIImage(named: "image 166")!
    static let image163 = UIImage(named: "image 163")!
    static let image160 = UIImage(named: "image 160")!

    static let polygon9 = UIImage(named: "Polygon 9")!
    static let polygon10 = UIImage(named: "Polygon 10")!
    
    static let image172 = UIImage(named: "image 172")!
    static let image173 = UIImage(named: "image 173")!
    
    static let image178 = UIImage(named: "image 178")!
    static let image179 = UIImage(named: "image 179")!
    
    static let image180 = UIImage(named: "image 180")!
    static let image181 = UIImage(named: "image 181")!
    
    static let image182 = UIImage(named: "image 182")!
    
    static let image158 = UIImage(named: "image 158")!
    static let qrCode3 = UIImage(named: "qr-code 3")!
    static let image157 = UIImage(named: "image 157")!
    
    static let image134 = UIImage(named: "image 134")!
    static let image141 = UIImage(named: "image 141")!
    
    static let image188 = UIImage(named: "image 188")!
    static let image189 = UIImage(named: "image 189")!
    
    static let popQuiz = UIImage(named: "POP QUIZ")!
    static let breakOver1 = UIImage(named: "BREAKOVER1")!
    
    static let image183 = UIImage(named: "image 183")!
    
    static let image185 = UIImage(named: "image 185")!
    static let image186 = UIImage(named: "image 186")!
    static let image187 = UIImage(named: "image 187")!
}

fileprivate func cropImage(_ image: UIImage, to rect: CGRect) -> UIImage? {
    guard let cgImage = image.cgImage?.cropping(to: rect) else { return nil }
    return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
}

fileprivate func rotateImage(_ image: UIImage, by angle: CGFloat) -> UIImage? {
    let radians = angle
    let newSize = CGSize(
        width: abs(cos(radians)) * image.size.width + abs(sin(radians)) * image.size.height,
        height: abs(sin(radians)) * image.size.width + abs(cos(radians)) * image.size.height
    )

    UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }

    // Move origin to center for rotation
    context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
    context.rotate(by: radians)

    // Draw the image centered
    image.draw(in: CGRect(
        x: -image.size.width / 2,
        y: -image.size.height / 2,
        width: image.size.width,
        height: image.size.height
    ))

    let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return rotatedImage
}

fileprivate func cropAndRotate(_ image: UIImage, cropRect: CGRect?, angle: CGFloat) -> UIImage? {
    var img = image
    if let rect = cropRect {
        guard let cropped = cropImage(img, to: rect) else { return nil }
        img = cropped
    }
    guard let rotated = rotateImage(img, by: angle) else { return nil }
    return rotated
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
    
    struct PolaroidBG<InnerContent: View> : View {
        private var oWidth: CGFloat = 300;
        private var oHeight: CGFloat = 340;
        var scaleFactor: CGFloat;
        var innerContent: InnerContent;
        
        init(@ViewBuilder innerContent: () -> InnerContent, width: CGFloat = .infinity, height: CGFloat = .infinity) {
            self.innerContent = innerContent();
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
                ZStack {
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
                    innerContent
                        .frame(width: 240, height: 215)
                        .background(.white)
                        .clipped()
                        .rotationEffect(Angle(degrees: -0.8))
                        .offset(y: -36)
                }
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
    
    struct DisappointmentBook : View {
        private var oWidth: CGFloat = 140;
        private var oHeight: CGFloat = 130;
        private var text: String;
        var scaleFactor: CGFloat;
        
        init(_ text: String = "", width: CGFloat = .infinity, height: CGFloat = .infinity) {
            if width == .infinity && height == .infinity {
                scaleFactor = 1;
            } else if height == .infinity {
                scaleFactor = width / oWidth;
            } else if height == .infinity {
                scaleFactor = height / oHeight;
            } else {
                scaleFactor = min(width / oWidth, height / oHeight)
            }
            self.text = text;
        }
        
        var body : some View {
            Group {
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 140, height: 130)
                        .background(
                            ImageAssets.disappointmentBook
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 158, height: 158)
                                .clipped()
                                .allowsHitTesting(false)
                        )
                        .clipped()
                    Text(text)
                        .font(FontTokens.architectsDaughter(size: 20))
                        .foregroundColor(ColorTokens.shade700)
                        .frame(width: 95, height: 25)
                        .minimumScaleFactor(0.5)
                        .offset(x: 25, y: 35)
                }
            }
            .frame(width: oWidth * scaleFactor, height: oHeight * scaleFactor)
            .scaleEffect(scaleFactor)
        }
    }
    
    struct DisappointmentStrip : View {
        private var oWidth: CGFloat = 300;
        private var oHeight: CGFloat = 65;
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
                  .frame(width: 300, height: 65)
                  .background(
                    ImageAssets.disappointmentStrip
                      .resizable()
                      .aspectRatio(contentMode: .fill)
                      .frame(width: 329, height: 70)
                      .offset(x: -10, y: -95)
                      .allowsHitTesting(false)
                  )
            }
            .frame(width: oWidth * scaleFactor, height: oHeight * scaleFactor)
            .scaleEffect(scaleFactor)
        }
    }
    
    struct DisappointmentChevron: View {
        private var oWidth: CGFloat = 35
        private var oHeight: CGFloat = 75
        var scaleFactor: CGFloat

        init(width: CGFloat = .infinity, height: CGFloat = .infinity) {
            if width == .infinity && height == .infinity {
                scaleFactor = 1
            } else if height == .infinity {
                scaleFactor = width / oWidth
            } else if width == .infinity {
                scaleFactor = height / oHeight
            } else {
                scaleFactor = min(width / oWidth, height / oHeight)
            }
        }

        var body: some View {
            Group {
                Rectangle()
                  .foregroundColor(.clear)
                  .frame(width: 35, height: 75)
                  .background(
                    ImageAssets.disappointmentChevron
                      .resizable()
                      .aspectRatio(contentMode: .fill)
                      .frame(width: 43, height: 79, alignment: .top)
                      .clipped()
                      .allowsHitTesting(false)
                      .offset(x: -3, y: -1)
                      .zIndex(-1)
                  )
                  .clipped()
            }
            .frame(width: oWidth * scaleFactor, height: oHeight * scaleFactor)
            .scaleEffect(scaleFactor)
        }
    }

    struct OnboardingHello70: View {
        private var oWidth: CGFloat = 105
        private var oHeight: CGFloat = 75
        var scaleFactor: CGFloat

        init(width: CGFloat = .infinity, height: CGFloat = .infinity) {
            if width == .infinity && height == .infinity {
                scaleFactor = 1
            } else if height == .infinity {
                scaleFactor = width / oWidth
            } else if width == .infinity {
                scaleFactor = height / oHeight
            } else {
                scaleFactor = min(width / oWidth, height / oHeight)
            }
        }

        var body: some View {
            Group {
                Rectangle()
                  .foregroundColor(.clear)
                  .frame(width: 105, height: 75)
                  .background(
                    ImageAssets.onboardingHello70
                      .resizable()
                      .aspectRatio(contentMode: .fill)
                      .frame(width: 120, height: 120, alignment: .top)
                      .clipped()
                      .allowsHitTesting(false)
                      .offset(x: 3, y: -1)
                      .zIndex(-1)
                  )
                  .clipped()
            }
            .frame(width: oWidth * scaleFactor, height: oHeight * scaleFactor)
            .scaleEffect(scaleFactor)
        }
    }
    
    struct FeedbackUpvoteButton: View {
        private var oWidth: CGFloat = 48
        private var oHeight: CGFloat = 52
        var scaleFactor: CGFloat

        init(width: CGFloat = .infinity, height: CGFloat = .infinity) {
            if width == .infinity && height == .infinity {
                scaleFactor = 1
            } else if height == .infinity {
                scaleFactor = width / oWidth
            } else if width == .infinity {
                scaleFactor = height / oHeight
            } else {
                scaleFactor = min(width / oWidth, height / oHeight)
            }
        }

        var body: some View {
            Group {
                Rectangle()
                  .foregroundColor(.clear)
                  .frame(width: oWidth, height: oHeight)
                  .background(alignment: .topLeading) {
                      ImageAssets.feedbackUpvoteButton
                          .resizable()
                          .aspectRatio(contentMode: .fill)
                          .frame(width: 52, height: 52, alignment: .top)
                          .clipped()
                          .allowsHitTesting(false)
                          .offset(x: -2, y: 0)
                          .zIndex(-1)
                  }
                  .clipped()
            }
            .frame(width: oWidth * scaleFactor, height: oHeight * scaleFactor)
            .scaleEffect(scaleFactor)
        }
    }
    
    struct UserInfoBackground: View {
        private var oWidth: CGFloat = 340;
        private var oHeight: CGFloat = 190;
        var scaleFactor: CGFloat;
        
        init(width: CGFloat = .infinity, height: CGFloat = .infinity) {
            if width == .infinity && height == .infinity {
                scaleFactor = 1;
            } else if height == .infinity {
                scaleFactor = width / oWidth;
            } else if width == .infinity {
                scaleFactor = height / oHeight;
            } else {
                scaleFactor = min(width / oWidth, height / oHeight)
            }
        }
        
        var body: some View {
            Group {
                Rectangle()
                  .foregroundColor(.clear)
                  .frame(width: oWidth, height: oHeight, alignment: .trailing)
                  .background(
                    ImageAssets.onboardingHello68
                      .resizable()
                      .aspectRatio(contentMode: .fill)
                      .frame(width: 370, height: 220.0034637451172, alignment: .bottom)
                      .clipped()
                      .offset(x: -10, y: 20)
                  )
                  .rotationEffect(Angle(degrees: -178))
            }
            .frame(width: oWidth * scaleFactor, height: oHeight * scaleFactor)
            .scaleEffect(scaleFactor)
        }
    }
    
    struct BoundPage: View {
        private var oWidth: CGFloat = 330;
        private var oHeight: CGFloat = 85;
        var scaleFactor: CGFloat;
        
        init(width: CGFloat = .infinity, height: CGFloat = .infinity) {
            if width == .infinity && height == .infinity {
                scaleFactor = 1;
            } else if height == .infinity {
                scaleFactor = width / oWidth;
            } else if width == .infinity {
                scaleFactor = height / oHeight;
            } else {
                scaleFactor = min(width / oWidth, height / oHeight)
            }
        }
        
        var body: some View {
            Group {
                Rectangle()
                  .foregroundColor(.clear)
                  .frame(width: oWidth, height: oHeight)
                  .background(
                    ImageAssets.postBoundPage
                      .resizable()
                      .aspectRatio(contentMode: .fill)
                      .frame(width: 359, height: 102)
                      .offset(x: -10, y: -100)
                  )
            }
            .frame(width: oWidth * scaleFactor, height: oHeight * scaleFactor)
            .scaleEffect(scaleFactor)
        }
    }
    
    static var Image145: UIImage {
        cropImage(ImageAssets.image145, to: CGRect(x: 0, y: 9, width: 54, height: 34))!
    }
    
    static var Image144: UIImage {
        cropImage(ImageAssets.image144, to: CGRect(x: 9, y: 4, width: 34, height: 42))!
    }
    
    static var Image124 = ImageAssets.image124;
    
    static var Image147: UIImage {
        cropImage(ImageAssets.image147, to: CGRect(x: 0, y: 0, width: 47, height: 43))!
    }
    
    static var Image146: UIImage = ImageAssets.image146;
    
    static var Image161: UIImage {
        cropImage(ImageAssets.image161, to: CGRect(x: 10, y: 20, width: 210, height: 260))!
    }
    
    static var Image164: UIImage {
        cropImage(ImageAssets.image164, to: CGRect(x: 135, y: 70, width: 575, height: 730))!
    }
    
    static var Image166: UIImage {
        cropImage(ImageAssets.image166, to: CGRect(x: 100, y: 57, width: 620, height: 758))!
    }
    
    static var Image163: UIImage {
        cropImage(ImageAssets.image163, to: CGRect(x: 82, y: 0, width: 693, height: 814))!
    }
    
    static var Image160: UIImage {
        cropImage(rotateImage(ImageAssets.image160, by: 0.3)!, to: CGRect(x: 150, y: 200, width: 815, height: 600))!
    }
    
    static var Polygon9: UIImage = ImageAssets.polygon9;
    
    static var Polygon10: UIImage  = ImageAssets.polygon10;
    
    static var Image172: UIImage {
        cropImage(ImageAssets.image172, to: CGRect(x: 100, y: 58, width: 635, height: 777))!
    }
    
    static var Image173: UIImage {
        cropImage(ImageAssets.image173, to: CGRect(x: 201, y: 208, width: 341, height: 484))!
    }
    
    static var Image180: UIImage {
        cropImage(ImageAssets.image180, to: CGRect(x: 0, y: 149, width: 839, height: 243))!
    }
    static var Image181: UIImage {
        cropImage(ImageAssets.image181, to: CGRect(x: 119, y: 63, width: 595, height: 755))!
    }
    
    static var Image182: UIImage {
        cropImage(ImageAssets.image182, to: CGRect(x: 27, y: 181, width: 771, height: 446))!
    }
    
    static var Image158: UIImage {
        cropImage(ImageAssets.image158, to: CGRect(x: 134, y: 83, width: 595, height: 663))!
    }
    static var QrCode3: UIImage {
        cropImage(ImageAssets.qrCode3, to: CGRect(x: 37, y: 43, width: 429, height: 425))!
    }
    static var Image157: UIImage {
        cropImage(ImageAssets.image157, to: CGRect(x: 59, y: 4, width: 716, height: 795))!
    }
    
    static var Image134: UIImage {
        cropImage(ImageAssets.image134, to: CGRect(x: 35, y: 205, width: 796, height: 563))!
    }
    
    static var Image141: UIImage {
        cropImage(ImageAssets.image141, to: CGRect(x: 624, y: 1135, width: 814, height: 244))!
    }
    
    static var Image188: UIImage {
        cropImage(ImageAssets.image188, to: CGRect(x: 148, y: 25, width: 478, height: 787))!
    }
    static var Image189: UIImage {
        cropImage(ImageAssets.image189, to: CGRect(x: 175, y: 232, width: 500, height: 464))!
    }
    
    static var PopQuiz: UIImage = ImageAssets.popQuiz
    
    static var BreakOver1: UIImage = ImageAssets.breakOver1
    
    static var Image183: UIImage {
        cropImage(ImageAssets.image183, to: CGRect(x: 95, y: 274, width: 716, height: 223))!
    }
    
    static var Image185: UIImage {
        cropImage(ImageAssets.image185, to: CGRect(x: 176, y: 87, width: 487, height: 690))!
    }
    static var Image186: UIImage {
        cropImage(ImageAssets.image186, to: CGRect(x: 30, y: 63, width: 774, height: 647))!
    }
    static var Image187: UIImage {
        cropImage(ImageAssets.image187, to: CGRect(x: 121, y: 88, width: 601, height: 651))!
    }
}

#Preview {
    ZStack {
        Color.black
        Image(uiImage: FormattedImages.Image161)
            .overlay(
                Rectangle()
                    .stroke(Color.red, lineWidth: 3)
            )
    }
}
