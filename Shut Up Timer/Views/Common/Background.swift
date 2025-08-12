import SwiftUI

struct Background : View {
    var body : some View {
        Rectangle()
            .foregroundColor(.clear)
            .background(
                Image(uiImage: ImageAssets.image153)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .ignoresSafeArea(edges: .all)
                    .allowsHitTesting(false)
            )
            .ignoresSafeArea(edges: .all)
            .allowsHitTesting(false)
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
        .frame(height: 40)
    }
}
