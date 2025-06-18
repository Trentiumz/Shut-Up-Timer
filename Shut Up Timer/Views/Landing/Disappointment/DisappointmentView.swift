import SwiftUI

// --- DisappointmentView Main ---
struct DisappointmentView: View {
    @EnvironmentObject var sessions: Sessions
    @EnvironmentObject var router: AppRouter

    /// albums: [(StringWriting, Month, Year)]
    var albums: [(String, Int, Int)] {
        let earliest = sessions.sessions.map { $0.started }.min(by: <) ?? Date()
        let calendar = Calendar.current
        let now = Date()
        var current = startOfMonth(earliest)
        var dates: [Date] = []
        while current <= now {
            dates.append(current)
            current = calendar.date(byAdding: .month, value: 1, to: current)!
        }
        
        return dates.map{ getMonthRep($0) }
    }
    
    func getMonthRep(_ date: Date) -> (String, Int, Int){
        let month = Calendar.current.component(.month, from: date)
        let year = Calendar.current.component(.year, from: date)
        let formatter = DateFormatter()
        return ("\(formatter.monthSymbols[month]) \(year)", month, year)
    }

    // Example: ["You're one more '5-minute break' away...", ...]
    var favouriteRoasts: [String] {
        sessions.getLatestRoasts()
    }

    // Called when a book is tapped
    func onAlbumTap(_ album: String) {
        // Implement navigation or filtering logic here
    }

    var body: some View {
        ZStack {
            Background()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // --- Monthly Albums ---
                    SectionStripe("Monthly Albums >")
                    HorizontalScroller(data: albums, itemWidth: 140, numItems: 2) { album in
                        Button(action: { router.toAlbumView(month: album.1, year: album.2) }) {
                            FormattedImages.DisappointmentBook(album.0, width: 140)
                        }
                    }
                    .padding(.leading, 10)
                    
                    // --- Favourite Roasts ---
                    HStack {
                        SectionStripe("Favourite Roasts >")
                        Spacer()
                        Image(systemName: "frying.pan")
                            .resizable()
                            .frame(width: 48, height: 32)
                            .rotationEffect(.degrees(-10))
                            .padding(.trailing, 12)
                    }
                    HorizontalScroller(data: Utils.chunked(favouriteRoasts, size: 2), itemWidth: 300, numItems: 1) { roast in
                        VStack(spacing: 20) {
                            RoastPaper(roast[0])
                            if roast.count > 1 {
                                RoastPaper(roast[1])
                            }
                        }
                    }
                    .padding(.leading, 10)
                    
                    // --- Stats Summary ---
                    SectionStripe("Stats Summary >")
                    HStack {
                        Spacer()
                        StatsSummaryView(sessions: sessions)
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

// --- Section Stripe ---
struct SectionStripe: View {
    var text: String
    init(_ text: String){
        self.text = text;
    }
    
    var body: some View {
        HStack {
            Spacer()
                .frame(maxWidth: 40)
            ZStack(alignment: .leading) {
                FormattedImages.FriendCodeStripe(width: 250)
                Text(text)
                    .font(FontTokens.architectsDaughter(size: 20))
                    .foregroundColor(ColorTokens.shade100)
                    .padding(.leading, 30)
            }
            .frame(height: 48)
        }
    }
}

// --- Roast Paper ---
fileprivate struct RoastPaper : View {
    var text: String;
    
    init(_ text: String) {
        self.text = text;
    }
    
    var body : some View {
        ZStack(alignment: .leading) {
            FormattedImages.DisappointmentStrip(width: 300)
            FormattedImages.LeaderboardBandage(width: 80)
                .rotationEffect(Angle(degrees: 90))
                .offset(x: -35)
            HStack {
                Spacer()
                    .frame(maxWidth: 35)
                Text(text)
                    .font(FontTokens.architectsDaughter(size: 20))
                    .minimumScaleFactor(0.4)
                    .foregroundColor(ColorTokens.shade700)
                    .frame(width: 250, height: 45, alignment: .topLeading)
            }
        }
    }
}

fileprivate func startOfMonth(_ date: Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month], from: date)
    if let date = calendar.date(from: components) {
        return date
    } else {
        print("Failed to get start of week for \(date)")
        return Date()
    }
}

fileprivate func startOfWeek(_ date: Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
    if let date = calendar.date(from: components) {
        return date
    } else {
        print("Failed to get start of week for \(date)")
        return Date()
    }
}

fileprivate func getWeekInfo(sessions: Sessions) -> [[TimeInterval?]] {
    let dateHours = sessions.getDateHours()
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    var result: [[TimeInterval?]] = []

    // For each week (0 = current, 1 = last week, ... 3 = 3 weeks ago)
    for weekIndex in 0..<4 {
        var week: [TimeInterval?] = []
        // For each day in the week (0 = Sunday, 6 = Saturday)
        for dayIndex in 0..<7 {
            // Calculate the date for this cell
            if let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekIndex, to: today),
               let date = calendar.date(byAdding: .day, value: dayIndex, to: startOfWeek(weekStart)) {
                let day = calendar.startOfDay(for: date)
                // If the day is after today, set to nil
                if day > today {
                    week.append(nil)
                } else {
                    week.append(dateHours[day, default: 0])
                }
            } else {
                week.append(nil)
            }
        }
        result.append(week)
    }
    return result
}

// --- Stats Summary View ---
fileprivate struct StatsSummaryView: View {
    var sessions: Sessions
    var weeks: [[TimeInterval?]]
    
    init(sessions: Sessions) {
        self.sessions = sessions;
        self.weeks = getWeekInfo(sessions: sessions);
        print(self.weeks)
    }

    // Helper: get color for hours
    func colorFor(time: TimeInterval) -> Color {
        let maxTime: TimeInterval = 24 * 60 * 60
        let t = min(1, time / maxTime * 3)
        return Color(.sRGB, red: 0.2, green: 0.7, blue: 0.2, opacity: 0.2 + 0.8 * t)
    }

    let dayLabels = ["S", "M", "Tu", "W", "Th", "F", "S"]

    func formatDate(_ date: Date) -> String {
        let day = Calendar.current.component(.day, from: date)
        return "\(day)"
    }
    
    func getRangeForInd(ind: Int) -> String {
        let calendar = Calendar.current
        if let weekStart = calendar.date(byAdding: .weekOfYear, value: -ind, to: Date()) {
            let weekStartSunday = startOfWeek(weekStart)
            if let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStartSunday) {
                return "\(formatDate(weekStartSunday))-\(formatDate(weekEnd))"
            }
        }
        print("Failed to get range index \(ind)")
        return ""
    }

    var body: some View {
        ZStack(alignment: .leading) {
            FormattedImages.LinedImageBackground(width: 340, height: 210)
                .cornerRadius(18)
            VStack(alignment: .leading, spacing: 10) {
                // Header row
                HStack(spacing: 8) {
                    Text("")
                        .frame(width: 25, height: 25) // empty label
                    ForEach(dayLabels, id: \.self) { label in
                        Text(label)
                            .font(FontTokens.architectsDaughter(size: 14))
                            .foregroundColor(.gray)
                            .frame(width: 25, height: 25)
                    }
                }
                
                
                // Data rows
                ForEach(Array(weeks.enumerated()), id: \.offset) { idx, week in
                    HStack(spacing: 8) {
                        Text(getRangeForInd(ind: idx))
                            .font(FontTokens.architectsDaughter(size: 10))
                            .frame(width: 25, height: 25)
                        // Week date range
                        ForEach(week.indices, id: \.self) { dayIdx in
                            if let time = week[dayIdx] {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(colorFor(time: time))
                                    .stroke(.black, lineWidth: 2)
                                    .frame(width: 25, height: 25)
                            } else {
                                Rectangle()
                                    .fill(.clear)
                                    .frame(width: 25, height: 25)
                            }
                        }
                    }
                }
            }
            .padding(.leading, 40)
        }
        .frame(width: 340, height: 210)
    }
}

#Preview {
    DisappointmentView()
        .environmentObject(Sessions(sessions: [
            SessionEntry(tasks: [], started: Date(), ended: Date(), timeLocked: 3600.0, plannedTime: 0, success: false, roast: "You’re one more '5-minute break' away from complete academic collapse."),
            SessionEntry(tasks: [], started: Date(), ended: Date(), timeLocked: 3600.0, plannedTime: 0, success: false, roast: "You’re one more '5-minute break' away from complete academic collapse."),
            SessionEntry(tasks: [], started: Date(), ended: Date(), timeLocked: 3600.0, plannedTime: 0, success: false, roast: "You’re one more '5-minute break' away from complete academic collapse."),
            SessionEntry(tasks: [], started: Date(), ended: Date(), timeLocked: 3600.0, plannedTime: 0, success: false, roast: "You’re one more '5-minute break' away from complete academic collapse."),
            SessionEntry(tasks: [], started: Date(), ended: Date(), timeLocked: 3600.0, plannedTime: 0, success: false, roast: "You’re one more '5-minute break' away from complete academic collapse."),
        ], onUpdate: {_ in}))
    // RoastPaper("You’re one more '5-minute break' away from complete academic collapse.")
}
