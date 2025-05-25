func parseISO(_ durationString: String) -> TimeInterval? {
    let formatter = ISO8601DateComponentsFormatter()
    formatter.formatOptions = [.withTime]
    return formatter.duration(from: durationString)
}

func toISO(_ duration: TimeInterval) -> String {
    let formatter = ISO8601DateComponentsFormatter()
    formatter.formatOptions = [.withTime]
    return formatter.string(from: duration) ?? ""
}