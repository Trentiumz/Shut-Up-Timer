import SwiftUI;
import FamilyControls

enum SettingsTab: CaseIterable {
    case timer
    case blockedApps  
    case account
    
    var title: String {
        switch self {
        case .timer: return "Timer"
        case .blockedApps: return "Blocked Apps" 
        case .account: return "Account"
        }
    }
}

struct SettingsView : View {
    // current settings
    @EnvironmentObject var settings: Settings;
    @EnvironmentObject var credManager: CredManager;
    @EnvironmentObject var router: AppRouter;
    @EnvironmentObject var curUser: CurUser
    @EnvironmentObject var sessions: SessionLoader;
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var selectedTab: SettingsTab = .timer
    @State private var showUsernameModal: Bool = false
    @State private var friends: [FriendProfileResponse] = []
    
    func updateUsername(newUsername: String) {
        guard (credManager.session?.user.id) != nil else { return }
        
        Task {
            do {
                // Call the change_username function
                try await credManager.supabaseClient.rpc("change_username", params: ["new_username": newUsername]).execute()

                curUser.refresh()
            } catch {
                print("Error updating username: \(error)")
            }
        }
    }
    
    func updateVisibility(field: String, newValue: Bool) {
        // Update server state
        Task {
            do {
                try await credManager.supabaseClient.rpc("update_\(field)_visibility", params: ["new_\(field)_visible": newValue]).execute()
                curUser.refresh()
            } catch {
                print("Error updating \(field) visibility: \(error)")
                curUser.refresh()
            }
        }
    }
    
    func updateFriends() {
        Task {
            do {
                let friendProfiles: [FriendProfileResponse] = try await credManager.supabaseClient.rpc("get_friend_profiles").execute().value
                await MainActor.run {
                    friends = friendProfiles
                }
            } catch {
                print("Error fetching friends: \(error)")
            }
        }
    }
    
    func removeFriend(_ friendId: UUID) {
        Task {
            do {
                try await credManager.supabaseClient.rpc("remove_friend", params: ["other_id": friendId]).execute()
                await MainActor.run {
                    updateFriends()
                }
            } catch {
                print("Error removing friend: \(error)")
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 7) {
            // User Profile Card
            UserProfileCard(selectedTab: $selectedTab, userIQ: curUser.userPublicProfile?.iq ?? 100)
                .zIndex(2)
            
            // Main Content Section
            MainContentCard(selectedTab: selectedTab, 
                          showUsernameModal: $showUsernameModal,
                          updateUsername: updateUsername,
                          updateVisibility: updateVisibility,
                          toLogout: {
                              Task {
                                  do {
                                      try await credManager.logOut();
                                      curUser.refresh()
                                  } catch {
                                      print("Error signing out: \(error)")
                                  }
                              }
                          })
        }
        .padding()
        .background(Background())
        .onAppear {
            curUser.refresh()
            updateFriends()
        }
        .onChange(of: credManager.session) { _ in
            curUser.refresh()
            updateFriends()
        }
        .sheet(isPresented: $showUsernameModal) {
            UsernameEditModal(
                currentUsername: curUser.userPublicProfile?.username ?? "",
                onSave: { newUsername in
                    updateUsername(newUsername: newUsername)
                    showUsernameModal = false
                },
                onCancel: {
                    showUsernameModal = false
                }
            )
        }
    }
}

// MARK: - Preview
struct SettingsPreview : PreviewProvider {
    struct Wrapper : View {
        @State var userPublicProfile: UserPublicProfileResponse? = nil;
        @State var userProfile: UserProfileResponse? = nil;
        var credManager = CredManager(subscriptionManager: SubscriptionManager())
        
        var body : some View {
            SettingsView()
            .environmentObject(AppRouter())
            .environmentObject(SettingsLoader.loadSettings())
            .environmentObject(credManager)
            .environmentObject(CurUser(credManager: credManager))
            .environmentObject(LiveActivityManager(fastAPIClient: credManager.fastAPI))
        }
    }
    
    static var previews : some View {
        Wrapper()
    }
}
