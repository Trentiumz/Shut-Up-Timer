import SwiftUI
import Supabase
import GoogleSignIn

/// Handles credentials and utility functions for communicating with various endpoints
class CredManager: ObservableObject {
    @Published var session: Session?
    @Published var connected: Bool = false
    @Published var loggedIn: Bool = false
    
    @Published var supabaseClient: SupabaseClient
    
    init() {
        // Initialize Supabase client with temporary keys
        supabaseClient = SupabaseClient(
                supabaseURL: URL(string: "https://oullomxexthybhywbgpr.supabase.co")!,
                supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im91bGxvbXhleHRoeWJoeXdiZ3ByIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU3NTYwMDYsImV4cCI6MjA2MTMzMjAwNn0.ox6uLdxPQ57WsBACWC2iVhn0akPUWBcQxTTAQ39kwdE"
            )
            
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
        try await supabaseClient.auth.signIn(email: email, password: password)
        let curSession = try await supabaseClient.auth.session;

        await MainActor.run {
            self.session = curSession;
            self.loggedIn = true;
            self.sendTokenToBackend()
        }
    }

    /// Handles Google OAuth login
    func loginGoogle() async throws {
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
    }

    // Handles logging out
    func logOut() async throws {
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
    
    func addFeedback(stars: Int, feedback: String) async -> Bool {
        print("Adding feedback...")
        if loggedIn {
            do {
                try await supabaseClient.rpc("add_feedback", params: ["stars": "\(stars)", "feedback": feedback]).execute()
                return true;
            } catch {
                print("Failed to add feedback: \(error.localizedDescription)")
                return false;
            }
        }
        print("Add Feedback not logged in")
        return false;
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
        guard let data = image.jpegData(compressionQuality: 0.8),
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
