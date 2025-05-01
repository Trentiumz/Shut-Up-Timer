import SwiftUI
import Supabase

class CredManager: ObservableObject {
    @Published var session: Session?
    @Published var connected: Bool = false
    @Published var loggedIn: Bool = false
    
    @Published var supabaseClient: SupabaseClient?
    
    init() {
        // Initialize Supabase client with temporary keys
        supabaseClient = SupabaseClient(
                supabaseURL: URL(string: "https://oullomxexthybhywbgpr.supabase.co")!,
                supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im91bGxvbXhleHRoeWJoeXdiZ3ByIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU3NTYwMDYsImV4cCI6MjA2MTMzMjAwNn0.ox6uLdxPQ57WsBACWC2iVhn0akPUWBcQxTTAQ39kwdE"
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