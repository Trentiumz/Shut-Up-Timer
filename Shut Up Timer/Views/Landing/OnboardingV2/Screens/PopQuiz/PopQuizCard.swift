import SwiftUI

// MARK: - PopQuiz Card

enum PopQuizHeaderStyle {
    case popQuiz
    case failure
}

struct PopQuizCard<InnerContent: View, CardOverlay: View>: View {
    let headerStyle: PopQuizHeaderStyle
    let innerContent: InnerContent
    let cardOverlay: CardOverlay
    let leftButton: AnyView
    let rightButton: AnyView
    
    init(
        headerStyle: PopQuizHeaderStyle = .popQuiz,
        @ViewBuilder content: () -> InnerContent,
        @ViewBuilder cardOverlay: () -> CardOverlay,
        @ViewBuilder leftButton: () -> some View,
        @ViewBuilder rightButton: () -> some View
    ) {
        self.headerStyle = headerStyle
        self.innerContent = content()
        self.cardOverlay = cardOverlay()
        self.leftButton = AnyView(leftButton())
        self.rightButton = AnyView(rightButton())
    }
    
    private var headerBanner: some View {
        Group {
            if headerStyle == .failure {
                HStack {
                    Spacer()
                    ZStack(alignment: .top) {
                        Image(uiImage: FormattedImages.Image180)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 7)
                            .offset(y: -8)
                            .allowsHitTesting(false)
                        
                        VStack(spacing: 0) {
                            Text("YOU'RE A...")
                                .font(FontTokens.architectsDaughter(size: 15))
                                .foregroundStyle(.white)
                            Text("FAILURE")
                                .font(FontTokens.architectsDaughter(size: 34))
                                .foregroundStyle(.white)
                                .padding(.top, -10)
                        }
                        .frame(height: 60, alignment: .top)
                        .padding(.top, 1)
                    }
                    Spacer()
                }
                .padding(.bottom, -48)
            } else {
                // Use provided Pop Quiz banner from FormattedImages
                Image(uiImage: FormattedImages.PopQuiz)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 48)
                    .padding(.bottom, -36)
                    .padding(.horizontal)
                    .padding(.leading)
                    .allowsHitTesting(false)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerBanner
                .zIndex(3)
            
            // Use the lined-paper image directly (not the generic LinedPopup)
            let paper = FormattedImages.Image134
            let aspect = paper.size.width / max(paper.size.height, 1)
            ZStack(alignment: .leading) {
                Image(uiImage: paper)
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(.degrees(2))
                
                // Inner content
                Group {
                    innerContent
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 18)
                .padding(.trailing, 24)
                .padding(.leading, 48)
            }
            .aspectRatio(aspect, contentMode: .fit)
            .overlay(cardOverlay, alignment: .bottomTrailing)
            .zIndex(2)
            
            // Buttons row
            HStack(spacing: 16) {
                leftButton
                rightButton
            }
            .padding(.top, 8)
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    ZStack {
        Color.black
        VStack {
            PopQuizCard(
                headerStyle: .failure,
                content: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Which has more value?")
                            .font(FontTokens.architectsDaughter(size: 24))
                        HStack(alignment: .top) {
                            Text("A. One boba\nB. 10X my focus")
                                .font(FontTokens.architectsDaughter(size: 24))
                                .lineLimit(3)
                                .minimumScaleFactor(0.7)
                            Spacer()
                                .layoutPriority(-1)
                            Spacer()
                                .frame(maxWidth: 120)
                        }
                    }
                }, cardOverlay: {
                    FormattedImages.PolaroidBG(innerContent: {
                        Color.black
                    }, width: 120)
                    .rotationEffect(Angle(degrees: 6))
                    .offset(x: -5, y: 10)
                }, leftButton: {
                    PopQuizSecondaryButton(title: "A. One boba", subtitle: "(only lasting 10min)", action: {})
                }, rightButton: {
                    PopQuizPrimaryButton(title: "B. 10X my focus", action: {})
                })
            .padding(5)
        }
    }
}


