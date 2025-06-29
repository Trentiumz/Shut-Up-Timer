import SwiftUI

@Observable
class CurUser {
    var userProfile: UserProfileResponse? = nil
    var userPublicProfile: UserPublicProfileResponse? = nil
    
    var credManager: CredManager
    
    init(credManager: CredManager) {
        self.credManager = credManager
        self.loadFromMemory()
    }
    
    func loadFromMemory() {
        let privateProfileData = UserDefaults.standard.data(forKey: "user-private-profile")
        let publicProfileData = UserDefaults.standard.data(forKey: "user-public-profile")
        if let liveData = privateProfileData {
            if let decoded = try? JSONDecoder().decode(UserProfileResponse.self, from: liveData) {
                userProfile = decoded
            } else {
                print("Incorrect Data Type (user private profile), got \(liveData)")
            }
        }
        if let liveData = publicProfileData {
            if let decoded = try? JSONDecoder().decode(UserPublicProfileResponse.self, from: liveData) {
                userPublicProfile = decoded
            } else {
                print("Incorrect Data Type (user public profile), got \(liveData)")
            }
        }
    }
    
    func saveToMemory() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: "user-private-profile")
        }
        if let encoded = try? JSONEncoder().encode(userPublicProfile) {
            UserDefaults.standard.set(encoded, forKey: "user-public-profile")
        }
    }
    
    func refresh(animated: Bool = false) {
        Task {
            do {
                let userId = credManager.supabaseClient.auth.currentUser?.id
                // Get public profile
                let publicProfile: [UserPublicProfileResponse] = try await credManager.supabaseClient.rpc("get_user_public_profile", params: ["user_id": userId]).execute().value
                // Get private profile
                let privateProfile: [UserProfileResponse] = try await credManager.supabaseClient.rpc("get_profile").execute().value
                
                await MainActor.run {
                    if privateProfile.count > 0 && publicProfile.count > 0 {
                        if animated {
                            withAnimation {
                                userPublicProfile = nil;
                                userProfile = nil;
                                userPublicProfile = publicProfile[0]
                                userProfile = privateProfile[0]
                            }
                        } else {
                            userPublicProfile = nil;
                            userProfile = nil;
                            userPublicProfile = publicProfile[0]
                            userProfile = privateProfile[0]
                        }
                        saveToMemory()
                    }
                }
            } catch {
                print("Error fetching user profiles: \(error)")
                await MainActor.run {
                    if animated {
                        withAnimation {
                            userPublicProfile = nil;
                            userProfile = nil;
                        }
                    } else {
                        userPublicProfile = nil;
                        userProfile = nil;
                    }
                    saveToMemory()
                }
            }
        }
    }
}
