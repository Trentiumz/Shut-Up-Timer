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
