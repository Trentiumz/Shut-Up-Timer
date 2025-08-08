import SwiftUI
import AuthenticationServices
import Supabase
import GoogleSignIn

/// Handles credentials and utility functions for communicating with various endpoints
class CredManager: ObservableObject {
    @Published var session: Auth.Session?
    @Published var connected: Bool = false
    @Published var loggedIn: Bool = false
    
    @Published var supabaseClient: SupabaseClient
    let fastAPI: FastAPIClient
    
    init(subscriptionManager: SubscriptionManager) {
        // Initialize Supabase client with temporary keys
        let supabaseClient = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseANON
        )
        self.supabaseClient = supabaseClient;
        
        fastAPI = FastAPIClient(supabase: supabaseClient, subscriptionManager: subscriptionManager)
            
        // Try to get the current session
        Task {
            do {
                let curSession = try await supabaseClient.auth.session;
                await MainActor.run {
                    self.session = curSession
                    self.connected = true
                    self.loggedIn = true
                    self.sendTokenToBackend()
                }
            } catch {
                print("Error initializing session: \(error)")
                await MainActor.run {
                    self.connected = true
                    self.loggedIn = false
                }
            }
        }
    }
    
    func sendTokenToBackend() {
        print("Sending token??")
        if self.loggedIn {
            if let token = UserDefaults.standard.string(forKey: "device-token-push") {
                print("Sending token \(token)")
                Task {
                    try await self.supabaseClient.rpc("set_apn", params: ["new_apn": token]).execute()
                }
            }
        }
    }

    // Handles email login 
    func loginEmail(email: String, password: String) async throws {
        AnalyticsManager.shared.trackLoginAttempt(method: "email")
        
        do {
            try await supabaseClient.auth.signIn(email: email, password: password)
            let curSession = try await supabaseClient.auth.session;

            await MainActor.run {
                self.session = curSession;
                self.loggedIn = true;
                self.sendTokenToBackend()
            }
            
            AnalyticsManager.shared.trackLoginSuccess(method: "email")
            
            // Set user ID for analytics
            if let userID = curSession.user.id.uuidString as String? {
                AnalyticsManager.shared.setUserId(userID)
                
                // Set user properties for analytics
                if let email = curSession.user.email {
                    AnalyticsManager.shared.setUserProperty(email, forName: "email")
                }
                AnalyticsManager.shared.setUserProperty("email", forName: "login_method")
            }
        } catch {
            AnalyticsManager.shared.trackLoginFailure(method: "email", error: error.localizedDescription)
            throw error
        }
    }

    /// Handles Google OAuth login
    func loginGoogle() async throws {
        AnalyticsManager.shared.trackLoginAttempt(method: "google")
        
        do {
            try await supabaseClient.auth.signInWithOAuth(
                provider: .google,
                redirectTo: URL(string: "shut-up-timer://login-callback")
            )

            let curSession = try await supabaseClient.auth.session;
            await MainActor.run {
                self.session = curSession;
                self.loggedIn = true;
                self.sendTokenToBackend()
            }
            
            AnalyticsManager.shared.trackLoginSuccess(method: "google")
            
            // Set user ID for analytics
            if let userID = curSession.user.id.uuidString as String? {
                AnalyticsManager.shared.setUserId(userID)
                
                // Set user properties for analytics
                if let email = curSession.user.email {
                    AnalyticsManager.shared.setUserProperty(email, forName: "email")
                }
                AnalyticsManager.shared.setUserProperty("google", forName: "login_method")
            }
        } catch {
            AnalyticsManager.shared.trackLoginFailure(method: "google", error: error.localizedDescription)
            throw error
        }
    }
    
    /// Handles Apple login, to be used with SignInWithAppleButton (for the result)
    func loginApple(result: Result<ASAuthorization, any Error>) async throws {
        AnalyticsManager.shared.trackLoginAttempt(method: "apple")
        
        do {
            guard let credential = try result.get().credential as? ASAuthorizationAppleIDCredential
            else {
                AnalyticsManager.shared.trackLoginFailure(method: "apple", error: "Invalid credential")
                return
            }
            guard let idToken = credential.identityToken
                .flatMap({ String(data: $0, encoding: .utf8) })
            else {
                AnalyticsManager.shared.trackLoginFailure(method: "apple", error: "Invalid ID token")
                return
            }
            let curSession = try await supabaseClient.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: idToken
                )
            )
            await MainActor.run {
                self.session = curSession
                self.loggedIn = true
                self.sendTokenToBackend()
            }
            
            AnalyticsManager.shared.trackLoginSuccess(method: "apple")
            
            // Set user ID for analytics
            if let userID = curSession.user.id.uuidString as String? {
                AnalyticsManager.shared.setUserId(userID)
                
                // Set user properties for analytics
                if let email = curSession.user.email {
                    AnalyticsManager.shared.setUserProperty(email, forName: "email")
                }
                AnalyticsManager.shared.setUserProperty("apple", forName: "login_method")
            }
        } catch {
            AnalyticsManager.shared.trackLoginFailure(method: "apple", error: error.localizedDescription)
            throw error
        }
    }

    // Handles logging out
    func logOut() async throws {
        AnalyticsManager.shared.trackLogout()
        try await supabaseClient.auth.signOut()
        await MainActor.run {
            self.session = nil
            self.loggedIn = false
        }
    }

    // Handles registration
    func register(email: String, password: String) async throws {
        try await supabaseClient.auth.signUp(
            email: email,
            password: password
        )

        let curSession = try await supabaseClient.auth.session;
        await MainActor.run {
            self.session = curSession;
            self.loggedIn = true;
            self.sendTokenToBackend()
        }
    }
    
    // ----------------------- Utility functions -----------------------
    func acceptFriendRequest(_ id: Int) async throws {
        if loggedIn {
            try await supabaseClient.rpc("accept_friend_request", params: ["request_id": "\(id)"]).execute()
        }
    }
    
    func removeFriendRequest(_ id: Int) async throws {
        if loggedIn {
            try await supabaseClient.rpc("remove_friend_request", params: ["request_id": "\(id)"]).execute()
        }
    }
    
    func removeFeedback(feedbackID: UUID) async -> Bool {
        print("Removing feedback \(feedbackID)...")
        if loggedIn {
            do {
                try await supabaseClient.rpc("remove_feedback", params: ["feedback_id": feedbackID]).execute()
                return true;
            } catch {
                print("Failed to remove feedback: \(error.localizedDescription)")
                return false;
            }
        }
        print("Remove Feedback not logged in")
        return false;
    }
    
    func getFeedbackByUpvotes() async -> [FeedbackResponse] {
        if loggedIn {
            do {
                let feedbacks: [FeedbackResponse] = try await supabaseClient.rpc("get_upvoted_feedback").execute().value
                return feedbacks
            } catch {
                print("Error getting feedback by upvotes: \(error)")
                return []
            }
        }
        return [];
    }
    
    func getFeedbackByRecent() async -> [FeedbackResponse] {
        if loggedIn {
            do {
                let feedbacks: [FeedbackResponse] = try await supabaseClient.rpc("get_recent_feedback").execute().value
                return feedbacks
            } catch {
                print("Error getting feedback by recent: \(error)")
                return []
            }
        }
        return [];
    }
    
    func getMyFeedback() async -> [FeedbackResponse] {
        if loggedIn {
            do {
                let feedbacks: [FeedbackResponse] = try await supabaseClient.rpc("get_my_feedback").execute().value
                return feedbacks
            } catch {
                print("Error getting my feedback: \(error)")
                return []
            }
        }
        return [];
    }
    
    func upvoteFeedback(feedbackID: UUID) async -> Bool {
        print("Upvoting feedback \(feedbackID)...")
        if loggedIn {
            do {
                try await supabaseClient.rpc("upvote_feedback", params: ["feedback_id": feedbackID]).execute()
                return true;
            } catch {
                print("Failed to upvote feedback: \(error.localizedDescription)")
                return false;
            }
        }
        print("Upvote Feedback not logged in")
        return false;
    }
    
    func removeUpvote(feedbackID: UUID) async -> Bool {
        print("Removing Upvote for feedback \(feedbackID)...")
        if loggedIn {
            do {
                try await supabaseClient.rpc("remove_upvote", params: ["feedback_id": feedbackID]).execute()
                return true;
            } catch {
                print("Failed to remove upvote: \(error.localizedDescription)")
                return false;
            }
        }
        print("Remove Upvote not logged in")
        return false;
    }
    
    // -------------------- User functions ---------------------------
    
    func uploadPFP(image: UIImage) async -> Bool {
        // Resize and crop image to 256x256 (or so that the minimum dimension is at most 256, cropping the center)
        let targetSize: CGFloat = 256
        let originalSize = image.size
        let minSide = min(originalSize.width, originalSize.height)
        let scale = targetSize / minSide
        let newWidth = originalSize.width * scale
        let newHeight = originalSize.height * scale
        
        // Resize
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Crop center
        let cropRect = CGRect(
            x: (newWidth - targetSize) / 2,
            y: (newHeight - targetSize) / 2,
            width: targetSize,
            height: targetSize
        )
        guard let resizedImage = resizedImage,
              let cgImage = resizedImage.cgImage?.cropping(to: cropRect) else { return false }
        let finalImage = UIImage(cgImage: cgImage)
        
        guard let data = finalImage.jpegData(compressionQuality: 0.8),
              let userID = session?.user.id else { return false; }
        let lowerUUID = userID.uuidString.lowercased()
        let filePath = "\(lowerUUID)/pfp_\(UUID().uuidString).jpg"
        do {
            let pfpPaths = try await supabaseClient.storage.from("profile-picture").list(path: "\(lowerUUID)")
            if !pfpPaths.isEmpty {
                let deletedPFP = try await supabaseClient.storage.from("profile-picture").remove(paths: pfpPaths.map{ "\(lowerUUID)/\($0.name)"})
                print("Deleted profile pictures: \(deletedPFP)")
            }
        } catch {
            print("Failed to delete pfp (for uploading): \(error.localizedDescription)")
        }
            
        do {
            try await supabaseClient.storage.from("profile-picture").upload(
                filePath,
                data: data,
                options: FileOptions(
                    cacheControl: "3600",
                    contentType: "image/jpeg"
                )
            )
            let publicURL = try supabaseClient.storage.from("profile-picture").getPublicURL(path: filePath)
            
            try await supabaseClient.rpc("change_profile_picture", params: [
                "new_profile_picture": publicURL
            ]).execute()
            return true;
        } catch {
            print("Failed to upload profile picture: \(error.localizedDescription), file path \(filePath)")
            return false;
        }
    }
    
    func getUserId() -> UUID? {
        return session?.user.id;
    }
}
