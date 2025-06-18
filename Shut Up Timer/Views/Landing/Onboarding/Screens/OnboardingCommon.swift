import SwiftUI;

struct LinedPaper : View {
    var text: String;
    var iconAlignment: Alignment;
    private var xOff: CGFloat, yOff: CGFloat;
    private var imageHeight: CGFloat;
    
    init(text: String, iconAlignment: Alignment, imageHeight: CGFloat = 374) {
        self.text = text;
        self.iconAlignment = iconAlignment;
        self.imageHeight = imageHeight;
        if iconAlignment == .topTrailing {
            xOff = 20;
            yOff = -110;
        } else if iconAlignment == .bottomTrailing {
            xOff = 40;
            yOff = 110;
        } else {
            xOff = 0;
            yOff = 0;
        }
    }
    
    var body : some View {
        ZStack {
            ZStack(alignment: iconAlignment) {
                Rectangle()
                    .fill(.clear)
                    .frame(width: 374, height: imageHeight, alignment: .top)
                    .background(
                        ImageAssets.onboardingHello68
                            .resizable()
                            .foregroundColor(.clear)
                            .frame(width: 400, height: 400, alignment: .top)
                            .clipped()
                            .aspectRatio(contentMode: .fill)
                            .offset(x: -10, y: -90),
                        alignment: .top
                    )
                    .clipped()
                ImageAssets.onboardingHello65
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 197, height: 197)
                    .clipped()
                    .offset(x: xOff, y: yOff)
            }
            Text(text)
                .font(Font.custom("ArchitectsDaughter-Regular", size: 30))
                .multilineTextAlignment(.center)
                .foregroundColor(ColorTokens.shade700)
                .frame(width: 292, alignment: .center)
                .rotationEffect(Angle(degrees: -2))
                .offset(x: 0, y: 20)
        }.allowsHitTesting(false)
    }
}

struct Background : View {
    var body : some View {
        Rectangle()
            .foregroundColor(.clear)
            .background(
                ImageAssets.onboardingHello67
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .ignoresSafeArea()
            )
            .ignoresSafeArea()
    }
}

struct BackButton : View {
    var onPress: () -> Void;
    
    var body : some View {
        HStack {
            Button(action: {
                onPress()
            }) {
                Text("←")
                    .font(Font.custom("ArchitectsDaughter-Regular", size: 40))
                    .foregroundColor(ColorTokens.shade700)
                    .clipped()
            }
            .padding(.horizontal)
            .frame(width: 80, height: 40)
            Spacer()
        }
    }
}

#Preview {
    ZStack {
        Background()
        VStack {
            BackButton(onPress: {})
            LinedPaper(text: "Hello There!", iconAlignment: .bottomTrailing, imageHeight: 240)
        }
    }
}
