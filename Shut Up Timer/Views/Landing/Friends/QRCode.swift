import SwiftUI
import CoreImage.CIFilterBuiltins

struct FriendQRInvite : View {
    var data: String;
    var userProfile: UserProfileResponse;
    @EnvironmentObject var curUser: CurUser
    @EnvironmentObject var router: AppRouter
    
    var body : some View {
        ZStack(alignment: .bottom) {
            FormattedImages.PolaroidBG(innerContent: {
                if let cgImage = generateQRCode(from: data) {
                    Image(uiImage: cgImage)
                        .resizable()
                } else {
                    Text("QR Code could not be generated")
                }
            }, width: 300)
            .overlay (
                HStack(alignment: .bottom) {
                    // Profile picture
                    PFPDisplay(
                        url: curUser.userPublicProfile?.profile_picture ?? "",
                        width: 60,
                        height: 60)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Code: \(userProfile.friend_code)")
                            .font(FontTokens.architectsDaughter(size: 18))
                            .foregroundColor(.black)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 2)
                            .cornerRadius(8)
                        // Requests button
                        Button(action: {
                            router.toViewRequests()
                        }) {
                            HStack(spacing: 5) {
                                Text("My Requests")
                                    .font(FontTokens.architectsDaughter(size: 14))
                                    .foregroundColor(.black)
                                
                                Circle()
                                    .fill(ColorTokens.red300)
                                    .frame(width: 8, height: 8)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(ColorTokens.shade300)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10),
                alignment: .bottom
            )
        }
    }
}

fileprivate func generateQRCode(from string: String) -> UIImage? {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    filter.message = Data(string.utf8)
    
    if let outputImage = filter.outputImage {
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
            return UIImage(cgImage: cgImage)
        }
    }
    return nil
}

#Preview("QR Code with Friend Code") {
    FriendQRInvite(data: "shutuptimer://friend-invite?code=123456789", userProfile: UserProfileResponse(friend_code: "123456", is_public_profile_visible: true, sessions: []))
        .environmentObject(CurUser(credManager: CredManager(subscriptionManager: SubscriptionManager())))
}
