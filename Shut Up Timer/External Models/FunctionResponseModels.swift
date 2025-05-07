import SwiftUI;
struct FriendLeaderboardResponse : Decodable {
    let friend_user_id: UUID
    let friend_username: String
    let friend_iq: Int
}

struct UserPublicProfileResponse : Decodable {
    let username: String
    let iq: Int
    let profile_picture: String
}

struct UserProfileResponse : Decodable {
    let friend_code: String
    let is_public_profile_visible: Bool
    let is_username_visible: Bool
    let is_iq_visible: Bool
    let is_profile_picture_visible: Bool
    let is_roasts_visible: Bool
    let is_disappointment_visible: Bool
}
