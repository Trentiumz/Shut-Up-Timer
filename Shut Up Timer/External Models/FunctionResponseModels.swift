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
    var friend_code: String
    var is_public_profile_visible: Bool
    var is_username_visible: Bool
    var is_iq_visible: Bool
    var is_profile_picture_visible: Bool
    var is_roasts_visible: Bool
    var is_disappointment_visible: Bool
}

struct FriendRequestResponse : Decodable {
    let id: Int
    let sender_id: UUID
    let receiver_id: UUID
    let created_at: Date
}
