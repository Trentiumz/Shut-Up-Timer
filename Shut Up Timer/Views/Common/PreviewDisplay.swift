import SwiftUI

struct RoastDisplay : View {
    let message: String;
    var body : some View {
        ZStack(alignment: .top) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 141, height: 141)
                .background(
                    ImageAssets.roastBackground
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 180, height: 180)
                        .clipped()
                )
            Text(message)
                .font(FontTokens.architectsDaughter(size: 28))
                .minimumScaleFactor(0.5)
                .foregroundColor(ColorTokens.shade100)
                .frame(width: 90, alignment: .topLeading)
                .frame(maxHeight: 80)
                .padding(.top, 15)
        }
    }
}

// --- FailImageDisplay: Carbon copy but for UIImage ---
struct FailImageDisplay: View {
    let image: UIImage
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 141, height: 141)
                .background(
                    ImageAssets.roastBackground
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 180, height: 180)
                        .clipped()
                )
            VStack {
                Spacer()
                    .frame(height: 11)
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 90, alignment: .center)
                    .background(.white)
                    .clipped()
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        RoastDisplay(message: "You're one more '5-minute break' away from collapse.")
        if let testImage = UIImage(systemName: "person.crop.square") {
            FailImageDisplay(image: testImage)
        }
    }
    .padding()
}
