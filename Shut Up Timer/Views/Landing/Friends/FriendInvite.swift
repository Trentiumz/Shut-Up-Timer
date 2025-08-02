import SwiftUI;
import AVFoundation;

enum FriendTab: CaseIterable {
    case myCode
    case scan
    
    var title: String {
        switch self {
        case .myCode:
            return "My Code"
        case .scan:
            return "Scan"
        }
    }
}

/// A view that handles friend-related functionality including:
/// - Displaying incoming friend requests
/// - Showing the user's friend code with QR code
/// - Allowing users to scan QR codes or enter friend codes
struct FriendInvite : View {
    @EnvironmentObject var credManager: CredManager;
    @EnvironmentObject var router: AppRouter;
    @State private var userProfile: UserProfileResponse? = nil;
    @State private var errorMessage: String? = nil;
    @State private var requestListRefreshTrigger = UUID();
    @State private var selectedTab = FriendTab.myCode;
    
    /// Fetches the user's profile information including their friend code (only works if we are logged in)
    func updateUserProfile() {
        userProfile = nil;
        
        guard credManager.loggedIn else { return }
        Task {
            do {
                let privateProfile: [UserProfileResponse] = try await credManager.supabaseClient.rpc("get_profile").execute().value
                if !privateProfile.isEmpty {
                    await MainActor.run {
                        userProfile = privateProfile[0]
                    }
                }
            } catch {
                print("Error fetching user profile: \(error)")
            }
        }
    }
    
    /// Sends a friend request to another user using their friend code
    func sendFriendRequest(friendCode: String) {
        guard credManager.loggedIn else { return };
        guard !friendCode.isEmpty else { return };
        
        Task {
            do {
                try await credManager.fastAPI.sendFriendRequest(FastAPIClient.SendFriendRequestParams(receiver_friend_code: friendCode))
                AnalyticsManager.shared.trackFriendRequestSent()
                await MainActor.run {
                    errorMessage = nil
                    // Trigger a refresh of the request list
                    requestListRefreshTrigger = UUID()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Background()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack(spacing: 0) {
                // Tab Navigation
                HStack(spacing: 0) {
                    ForEach(FriendTab.allCases, id: \.self) { tab in
                        Button(action: {
                            withAnimation {
                                selectedTab = tab
                            }
                        }) {
                            Text(tab.title)
                                .font(FontTokens.architectsDaughter(size: 24))
                                .minimumScaleFactor(0.7)
                                .lineLimit(1)
                                .foregroundColor(selectedTab == tab ? ColorTokens.shade100 : ColorTokens.shade700)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(
                                    Rectangle()
                                        .fill(selectedTab == tab ? ColorTokens.red300 : ColorTokens.shade200)
                                        .overlay(
                                            Rectangle()
                                                .inset(by: 0)
                                                .stroke(ColorTokens.shade100, lineWidth: 3)
                                        )
                                )
                        }
                    }
                }
                .padding(.top, 10)
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    MyCodeView(
                        userProfile: userProfile,
                        errorMessage: errorMessage,
                        onSendRequest: sendFriendRequest
                    )
                    .tag(FriendTab.myCode)
                    
                    ScanView(
                        errorMessage: errorMessage,
                        onSendRequest: sendFriendRequest
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tag(FriendTab.scan)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .padding(.horizontal, 40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            updateUserProfile()
        }
        .onChange(of: credManager.session) { _ in
            updateUserProfile()
        }
    }
}

struct CodeDisplay : View {
    var code: String;
    var body : some View {
        ZStack {
            FormattedImages.FriendCodeStripe(width: 320)
            Text("Code: \(code)")
                .font(FontTokens.architectsDaughter(size: 30))
                .foregroundColor(ColorTokens.shade100)
        }
    }
}

struct FriendCodeAdd : View {
    @State var text: String = "";
    var onCommit: (String) -> Void
    
    var body : some View {
        ZStack {
            FormattedImages.FriendCodeStripe(width: 320)
            TextField("", text: $text, onCommit: {
                onCommit(text)
                text = ""
            })
                .font(FontTokens.architectsDaughter(size: 25))
                .minimumScaleFactor(0.2)
                .foregroundColor(ColorTokens.shade100)
                .frame(width: 280)
            if text.isEmpty {
                Text("Enter Friend Code")
                    .font(FontTokens.architectsDaughter(size: 25))
                    .minimumScaleFactor(0.2)
                    .foregroundStyle(ColorTokens.shade300)
                    .multilineTextAlignment(.leading)
                    .frame(width: 280, alignment: .leading)
                    .allowsHitTesting(false)
            }
        }
    }
}

#Preview {
    FriendInvite()
        .environmentObject(CredManager())
}
