import Foundation

func parseISO(_ isoString: String) -> TimeInterval? {
    guard isoString.starts(with: "PT") else { return nil }

    let pattern = #"(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?"#
    let timeString = String(isoString.dropFirst(2)) // Remove "PT"

    guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
    guard let match = regex.firstMatch(in: timeString, range: NSRange(timeString.startIndex..., in: timeString)) else {
        return nil
    }

    func extractComponent(_ index: Int) -> TimeInterval {
        let nsRange = match.range(at: index)
        guard nsRange.location != NSNotFound,
              let range = Range(nsRange, in: timeString),
              let value = Double(timeString[range]) else {
            return 0
        }
        return value
    }

    let hours = extractComponent(1)
    let minutes = extractComponent(2)
    let seconds = extractComponent(3)

    return hours * 3600 + minutes * 60 + seconds
}

func toISO(_ duration: TimeInterval) -> String {
    let hours = Int(duration) / 3600
    let minutes = (Int(duration) % 3600) / 60
    let seconds = Int(duration) % 60

    var result = "PT"
    if hours > 0 { result += "\(hours)H" }
    if minutes > 0 { result += "\(minutes)M" }
    if seconds > 0 || result == "PT" { result += "\(seconds)S" }

    return result
}
