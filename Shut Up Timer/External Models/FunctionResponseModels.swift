import SwiftUI;
struct FriendLeaderboardResponse : Decodable {
    let friend_user_id: UUID
    let friend_username: String
    let friend_iq: Int
}

struct FriendProfileResponse : Decodable {
    let friend_user_id: UUID
    let friend_username: String
    let friend_iq: Int
    let friend_profile_picture: String
}

struct UserPublicProfileResponse : Decodable {
    var username: String
    var iq: Int
    var profile_picture: String
}

struct UserProfileResponse : Decodable {
    var friend_code: String
    var is_public_profile_visible: Bool
}

struct FriendRequestResponse : Decodable {
    let id: Int
    let sender_id: UUID
    let receiver_id: UUID
    let created_at: Date
}
