import SwiftUI
import CoreImage.CIFilterBuiltins

struct FriendQRInvite : View {
    var data: String;
    
    var body : some View {
        ZStack(alignment: .top) {
            FormattedImages.FriendQRBackground(width: 300)
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
            QRCodeView(data: data, width: 240, height: 220)
                .offset(y: 8)
                .rotationEffect(Angle(degrees: -0.5))
        }
    }
}

struct QRCodeView: View {
    let data: String
    let width: CGFloat
    let height: CGFloat
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        if let qrImage = generateQRCode(from: data) {
            Image(uiImage: qrImage)
                .interpolation(.none)
                .resizable()
                .frame(width: width, height: height)
                .padding()
        } else {
            Text("Failed to generate QR Code")
                .foregroundColor(.red)
        }
    }

    private func generateQRCode(from string: String) -> UIImage? {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}

#Preview {
    FriendQRInvite(data: "shutuptimer://friend-invite?code=123456789")
}
