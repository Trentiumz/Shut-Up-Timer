import Foundation

struct SessionEntry: Identifiable, Codable, Equatable {
    var id = UUID()
    var todoID: UUID
    var started: Date
    var ended: Date
    var timeLocked: TimeInterval
    var success: Bool
}
