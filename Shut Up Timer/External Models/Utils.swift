func parseISO(_ durationString: String) -> TimeInterval? {
    let formatter = ISO8601DateComponentsFormatter()
    formatter.formatOptions = [.withTime]
    return formatter.duration(from: durationString)
}