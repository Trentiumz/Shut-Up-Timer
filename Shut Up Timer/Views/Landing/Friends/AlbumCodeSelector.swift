import SwiftUI
import PhotosUI

struct AlbumCodeSelector<Content: View>: View {
    @State private var pickedImage: PhotosPickerItem?
    let onCodeUpdate: (String) -> Void
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        PhotosPicker(
            selection: $pickedImage,
            matching: .images,
            photoLibrary: .shared()
        ) {
            content()
        }
        .onChange(of: pickedImage) { newVal in
            Task {
                if let data = try? await newVal?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    if let qrCode = QRCodeDetector.detectQRCode(in: image) {
                        await MainActor.run {
                            onCodeUpdate(qrCode)
                        }
                    }
                }
            }
        }
    }
}

#Preview("Album Code Selector") {
    AlbumCodeSelector(onCodeUpdate: { code in
        print("Detected QR code: \(code)")
    }) {
        Text("Select Photo")
            .font(FontTokens.architectsDaughter(size: 18))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(ColorTokens.red300)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(ColorTokens.shade100, lineWidth: 2)
            )
    }
} 