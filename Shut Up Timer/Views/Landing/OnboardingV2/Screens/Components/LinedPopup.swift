import SwiftUI

/// A responsive popup that displays a lined paper background with a red bandage tape on top
/// and renders arbitrary content inside with padding.
struct LinedPopup<InnerContent: View>: View {
    private let verticalPadding: CGFloat
    private let trailingPadding: CGFloat
    private let tapeWidth: CGFloat
    private let tapeYOffset: CGFloat
    private let innerContent: InnerContent

    /// - Parameters:
    ///   - contentPadding: Padding applied between the inner content and the lined paper edges.
    ///   - tapeWidthRatio: Width of the red bandage as a fraction of the popup width. Defaults to 0.45.
    ///   - tapeYOffset: Vertical offset for the bandage (negative values move it upward).
    ///   - content: Arbitrary content to display inside the lined paper.
    init(
        verticalPadding: CGFloat = 24,
        trailingPadding: CGFloat = 12,
        tapeWidth: CGFloat = 180,
        tapeYOffset: CGFloat = -16,
        @ViewBuilder content: () -> InnerContent
    ) {
        self.verticalPadding = verticalPadding
        self.trailingPadding = trailingPadding
        self.tapeWidth = tapeWidth
        self.tapeYOffset = tapeYOffset
        self.innerContent = content()
    }

    private var backgroundImage: UIImage { FormattedImages.Image134 }
    private var bandageImage: UIImage { FormattedImages.Image141 }

    var body: some View {
        // Use the background image's aspect ratio so the view scales responsively with available width
        let aspectRatio = backgroundImage.size.width / max(backgroundImage.size.height, 1)

        ZStack(alignment: .top) {
            Image(uiImage: backgroundImage)
                .resizable()
                .rotationEffect(Angle(degrees: 2))
                .scaledToFit()

            // Bandage tape sized relative to the popup width
            Image(uiImage: bandageImage)
                .resizable()
                .scaledToFit()
                .frame(width: tapeWidth)
                .offset(y: tapeYOffset)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .allowsHitTesting(false)

            // Inner content with padding on all sides
            VStack { innerContent }
                .padding(.vertical, verticalPadding)
                .padding(.trailing, trailingPadding)
                .padding(.leading, 48)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            LinedPopup {
                VStack(alignment: .leading, spacing: 8) {
                    Text("This is a lined popup.")
                        .font(FontTokens.architectsDaughter(size: 18))
                        .foregroundStyle(ColorTokens.shade700)
                    Text("Add any SwiftUI view inside with padding.")
                        .font(FontTokens.architectsDaughter(size: 16))
                        .foregroundStyle(ColorTokens.shade700)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: 360)

            // Demonstrate responsiveness with a narrower width
            LinedPopup(verticalPadding: 16) {
                Text("Narrow width")
                    .font(FontTokens.architectsDaughter(size: 16))
            }
            .frame(width: 260)
        }
        .padding()
        .background(ColorTokens.shade100)
    }
}


