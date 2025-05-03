import SwiftUI
import Supabase

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

    // Handles email login 
    async func loginEmail(email: String, password: String) throws {
        await supabaseClient.auth.signIn(email: email, password: password)
        let curSession = await supabaseClient.auth.session;

        await MainActor.run {
            self.session = curSession;
            self.loggedIn = true;
        }
    }

    /// Handles Google OAuth login
    async func loginGoogle() throws {
        await credManager.supabaseClient.auth.signInWithOAuth(
            provider: .google,
            redirectTo: URL(string: "shut-up-timer://login-callback")
        )

        let curSession = await supabaseClient.auth.session;
        await MainActor.run {
            self.session = curSession;
            self.loggedIn = true;
        }
    }

    // Handles logging out
    async func logOut() throws {
        await supabaseClient.auth.signOut()
        await MainActor.run {
            self.session = nil
            self.loggedIn = false
        }
    }

    // Handles registration
    async func register(email: String, password: String) throws {
        await credManager.supabaseClient.auth.signUp(
            email: email,
            password: password
        )

        let curSession = await supabaseClient.auth.session;
        await MainActor.run {
            self.session = curSession;
            self.loggedIn = true;
        }
    }
}
