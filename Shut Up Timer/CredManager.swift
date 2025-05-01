import SwiftUI
import Supabase

class CredManager: ObservableObject {
    @Published var session: Session?
    @Published var connected: Bool = false
    @Published var loggedIn: Bool = false
    
    private var supabaseClient: SupabaseClient?
    
    init() {
        // Initialize Supabase client with temporary keys
        supabaseClient = SupabaseClient(
            supabaseURL: URL(string: "https://your-project.supabase.co")!,
            supabaseKey: "your-anon-key"
        )
        
        // Try to get the current session
        Task {
            do {
                if let session = try await supabaseClient?.auth.session {
                    await MainActor.run {
                        self.session = session
                        self.connected = true
                        self.loggedIn = true
                    }
                } else {
                    await MainActor.run {
                        self.connected = true
                        self.loggedIn = false
                    }
                }
            } catch {
                print("Error initializing session: \(error)")
                await MainActor.run {
                    self.connected = false
                    self.loggedIn = false
                }
            }
        }
    }
} 