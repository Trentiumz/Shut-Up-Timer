import SwiftUI
import CoreData

struct StatsSummaryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab: StatsTab = .yourStats
    @State private var selectedDate: Date? = nil
    @State private var showingDayDetail = false
    
    // Weekly hours calculated from database
    @State private var weeklyHours: [String: Double] = [
        "SUN": 0.0, "MON": 0.0, "TUE": 0.0, "WED": 0.0, "THU": 0.0, "FRI": 0.0, "SAT": 0.0
    ]
    
    enum StatsTab: CaseIterable {
        case yourStats
        case sessionLogs
        
        var title: String {
            switch self {
            case .yourStats: return "Your Stats"
            case .sessionLogs: return "Session Logs"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Tab buttons at the top
            HStack(spacing: 0) {
                ForEach(StatsTab.allCases, id: \.self) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        Text(tab.title)
                            .font(FontTokens.architectsDaughter(size: 16))
                            .foregroundColor(selectedTab == tab ? ColorTokens.shade700 : ColorTokens.shade100)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                            .frame(minWidth: 90, minHeight: 30)
                            .background(
                                Rectangle()
                                    .fill(selectedTab == tab ? ColorTokens.shade200 : ColorTokens.red300)
                                    .frame(minHeight: 60)
                                    .overlay(
                                        Rectangle()
                                            .inset(by: 0)
                                            .stroke(.black, lineWidth: 2)
                                    ),
                                alignment: .top
                            )
                    }
                }
            }
            .padding(.top, 10)
            
            // Main content area
            Group {
                if selectedTab == .yourStats {
                    if showingDayDetail, let selectedDate = selectedDate {
                        DayDetailView(date: selectedDate, onBack: {
                            showingDayDetail = false
                        })
                    } else {
                        YourStatsView(
                            weeklyHours: $weeklyHours,
                            selectedDate: $selectedDate,
                            showingDayDetail: $showingDayDetail
                        )
                    }
                } else {
                    SessionLogsView()
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(ColorTokens.shade200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .inset(by: 0)
                            .stroke(.black, lineWidth: 2)
                    )
            )
        }
    }
}

// MARK: - Your Stats View (Group 180)
struct YourStatsView: View {
    @Binding var weeklyHours: [String: Double]
    @Binding var selectedDate: Date?
    @Binding var showingDayDetail: Bool
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var currentWeek: Date = Date()
    
    // Fetch goals
    @FetchRequest(
        entity: Goal.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Goal.order, ascending: true)],
        predicate: NSPredicate(format: "redeemed == false")
    ) private var goals: FetchedResults<Goal>
    
    private let daysOfWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(getWeekRangeText())
                    .font(FontTokens.architectsDaughter(size: 14))
                    .foregroundColor(.black)
            }
            HStack(spacing: 0) {
                // Left arrow
                Button(action: {
                    withAnimation {
                        currentWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeek) ?? currentWeek
                        updateWeeklyHours()
                    }
                }) {
                    ZStack {
                        RoundedTriangle(direction: .left)
                            .fill(Color.gray)
                            .frame(width: 20, height: 80)
                        RoundedTriangle(direction: .left)
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 20, height: 80)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 10)
                
                // Bar chart
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(daysOfWeek, id: \.self) { day in
                        VStack(spacing: 0) {
                            // Bar
                            Group {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(ColorTokens.red300)
                                    .frame(width: 20, height: min(200, CGFloat(weeklyHours[day] ?? 0) * 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                                    .onTapGesture {
                                        selectedDate = getDateForDay(day)
                                        showingDayDetail = true
                                    }
                            }
                            .frame(maxWidth: .infinity)
                            
                            // Hours label
                            Group {
                                Text("\(String(format: "%.1f", weeklyHours[day] ?? 0))hr")
                                    .font(FontTokens.architectsDaughter(size: 12))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.black)
                            }
                            .frame(height: 15)
                            
                            // Day label
                            Text(day)
                                .font(FontTokens.architectsDaughter(size: 12))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .layoutPriority(5)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 0)
                .frame(minHeight: 100, alignment: .bottom)
                
                // Right arrow
                Button(action: {
                    withAnimation {
                        currentWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentWeek) ?? currentWeek
                        updateWeeklyHours()
                    }
                }) {
                    ZStack {
                        RoundedTriangle(direction: .right)
                            .fill(Color.gray)
                            .frame(width: 20, height: 80)
                        RoundedTriangle(direction: .right)
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 20, height: 80)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 10)
            }
            
            Spacer()
                .frame(maxHeight: 15)
        }
        .onAppear {
            updateWeeklyHours()
        }
    }
    
    private func getDateForDay(_ day: String) -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentWeek)
        let dayIndex = daysOfWeek.firstIndex(of: day) ?? 0
        let daysToAdd = dayIndex - (weekday - 1)
        return calendar.date(byAdding: .day, value: daysToAdd, to: currentWeek) ?? currentWeek
    }
    
    private func getWeekRangeText() -> String {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: currentWeek)?.start ?? currentWeek
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? currentWeek
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        let startText = dateFormatter.string(from: startOfWeek)
        let endText = dateFormatter.string(from: endOfWeek)
        
        return "\(startText) - \(endText)"
    }
    
    private func updateWeeklyHours() {
        let calendar = Calendar.current
        
        // Calculate start and end of the week
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: currentWeek)?.start ?? currentWeek
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) ?? currentWeek
        
        // Create fetch request for sessions in this week
        let fetchRequest: NSFetchRequest<Session> = Session.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "started >= %@ AND started < %@", startOfWeek as NSDate, endOfWeek as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Session.started, ascending: true)]
        
        do {
            let sessions = try viewContext.fetch(fetchRequest)
            
            // Initialize weekly hours
            var newWeeklyHours: [String: Double] = [:]
            for day in daysOfWeek {
                newWeeklyHours[day] = 0.0
            }
            
            // Calculate hours per day
            for session in sessions {
                guard !session.isDeleted, let started = session.started else { continue }
                
                let dayOfWeek = calendar.component(.weekday, from: started)
                let dayIndex = dayOfWeek - 1 // Calendar weekday is 1-based, array is 0-based
                let dayKey = daysOfWeek[dayIndex]
                
                let hours = session.timeLocked / 3600
                newWeeklyHours[dayKey, default: 0] += hours
            }
            
            weeklyHours = newWeeklyHours
        } catch {
            print("Failed to fetch sessions for weekly hours: \(error)")
        }
    }
}

// MARK: - Day Detail View (Group 191)
struct DayDetailView: View {
    let date: Date
    let onBack: () -> Void
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch sessions for the selected date
    @FetchRequest private var taskLogs: FetchedResults<TaskLog>
    
    // Fetch all goals and sort by progress
    @FetchRequest(
        entity: Goal.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Goal.order, ascending: true)],
        predicate: NSPredicate(format: "redeemed == false")
    ) private var allGoals: FetchedResults<Goal>
    
    init(date: Date, onBack: @escaping () -> Void) {
        self.date = date
        self.onBack = onBack
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        _taskLogs = FetchRequest(
            entity: TaskLog.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "session.started >= %@ AND session.started < %@", startOfDay as NSDate, endOfDay as NSDate)
        )
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Header with back button
            HStack {
                Spacer()
                
                Text(dateFormatter.string(from: date))
                    .font(FontTokens.architectsDaughter(size: 16))
                    .foregroundColor(.black)
            }
            
            // Content with constrained height
            HStack(alignment: .bottom, spacing: 20) {
                                // Left side - Tasks (only show if there are sessions)
                if !taskLogs.isEmpty {
                    TaskStatsView(taskStats: getTaskStats())
                }
                
                // Right side - Goals
                GoalStatsView(goals: safeGoals, date: date)
            }
        }.overlay(
            VStack {
                HStack {
                    Button(action: {
                        onBack()
                    }) {
                        Circle()
                            .fill(ColorTokens.red300)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle()
                                    .inset(by: 1)
                                    .stroke(.white, lineWidth: 2)
                            )
                            .overlay(
                                Text("<")
                                    .font(FontTokens.architectsDaughter(size: 24))
                                    .foregroundColor(.white)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                Spacer()
            }
        )
    }
    
    struct SectionLabel: View {
        var val: String
        var minWidth: CGFloat
        
        var body: some View {
            Text(val)
                .font(FontTokens.architectsDaughter(size: 14))
                .foregroundColor(.white)
                .padding(.vertical, 2)
                .frame(minWidth: minWidth)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ColorTokens.brown500)
                )
        }
    }
    
    struct TaskStatsView: View {
        let taskStats: [TaskStat]
        @State private var currentChunkIndex = 0
        @State private var taskBarWidth: CGFloat? = nil
        
        private var taskChunks: [[TaskStat]] {
            return Utils.chunked(taskStats, size: 3)
        }
        
        var body: some View {
            VStack(alignment: .center, spacing: 15) {
                // Task bars with navigation
                HStack(spacing: 0) {
                    // Left arrow for tasks
                    if taskChunks.count > 1 && currentChunkIndex > 0 {
                        Button(action: {
                            withAnimation {
                                currentChunkIndex = max(0, currentChunkIndex - 1)
                            }
                        }) {
                            ZStack {
                                RoundedTriangle(direction: .left)
                                    .fill(Color.gray)
                                    .frame(width: 20, height: 60)
                                RoundedTriangle(direction: .left)
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 20, height: 60)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                        .frame(maxWidth: 8)
                    
                    // Task content - show three tasks at a time
                    if let currentChunk = taskChunks.dropFirst(currentChunkIndex).first {
                        GeometryReader { geo in
                            HStack(alignment: .bottom, spacing: 12) {
                                ForEach(Array(currentChunk.enumerated()), id: \.element.todo.id) { index, taskStat in
                                    if !taskStat.todo.isDeleted {
                                        TaskBarView(taskStat: taskStat, showNameOnTop: index % 2 == 1, frameHeight: geo.size.height)
                                    }
                                }
                            }
                            .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            BGSizeReader(width: $taskBarWidth)
                            )
                        }
                    
                    // Right arrow for tasks
                    if taskChunks.count > 1 && currentChunkIndex < taskChunks.count - 1 {
                        Button(action: {
                            withAnimation {
                                currentChunkIndex = min(taskChunks.count - 1, currentChunkIndex + 1)
                            }
                        }) {
                            ZStack {
                                RoundedTriangle(direction: .right)
                                    .fill(Color.gray)
                                    .frame(width: 20, height: 60)
                                RoundedTriangle(direction: .right)
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 20, height: 60)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // Tasks label at bottom
                SectionLabel(val: "Tasks", minWidth: taskBarWidth ?? 0)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    struct GoalStatsView: View {
        let goals: [Goal]
        let date: Date
        @State private var currentChunkIndex = 0
        @State private var goalBarWidth: CGFloat? = nil
        
        private var sortedGoals: [Goal] {
            return goals.filter { !$0.isDeleted }.sorted { goal1, goal2 in
                // Get progress before the selected date
                let progress1 = try? goal1.getLatestProgress(before: date)
                let progress2 = try? goal2.getLatestProgress(before: date)
                
                let ratio1 = progress1?.iqGoal ?? 0 > 0 ? (progress1?.iqCurrent ?? 0) / (progress1?.iqGoal ?? 1) : 0
                let ratio2 = progress2?.iqGoal ?? 0 > 0 ? (progress2?.iqCurrent ?? 0) / (progress2?.iqGoal ?? 1) : 0
                
                // Sort by progress ratio (highest first), then by goal name
                if ratio1 != ratio2 {
                    return ratio1 > ratio2
                } else {
                    return (goal1.goal ?? "") < (goal2.goal ?? "")
                }
            }
        }
        
        private var goalChunks: [[Goal]] {
            return Utils.chunked(sortedGoals, size: 2)
        }
        
        var body: some View {
            VStack(alignment: .center, spacing: 15) {
                Spacer()
                // Goals with navigation
                HStack(spacing: 4) {
                    // Left arrow for goals
                    if goalChunks.count > 1 && currentChunkIndex > 0 {
                        Button(action: {
                            withAnimation {
                                currentChunkIndex = max(0, currentChunkIndex - 1)
                            }
                        }) {
                            ZStack {
                                RoundedTriangle(direction: .left)
                                    .fill(Color.gray)
                                    .frame(width: 20, height: 60)
                                RoundedTriangle(direction: .left)
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 20, height: 60)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Goal content - show two goals at a time
                    VStack(spacing: 12) {
                        if let currentGoalChunk = goalChunks.dropFirst(currentChunkIndex).first {
                            ForEach(currentGoalChunk, id: \.id) { goal in
                                if !goal.isDeleted {
                                    GoalProgressView(goal: goal, date: date)
                                }
                            }
                        }
                    }
                    .background(
                        BGSizeReader(width: $goalBarWidth)
                    )
                    .frame(maxWidth: .infinity)
                    
                    // Right arrow for goals
                    if goalChunks.count > 1 && currentChunkIndex < goalChunks.count - 1 {
                        Button(action: {
                            withAnimation {
                                currentChunkIndex = min(goalChunks.count - 1, currentChunkIndex + 1)
                            }
                        }) {
                            ZStack {
                                RoundedTriangle(direction: .right)
                                    .fill(Color.gray)
                                    .frame(width: 20, height: 60)
                                RoundedTriangle(direction: .right)
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 20, height: 60)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
                
                // Goals label at bottom
                SectionLabel(val: "Goals", minWidth: goalBarWidth ?? 0)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    struct TaskBarView: View {
        let taskStat: TaskStat
        let showNameOnTop: Bool
        let frameHeight: CGFloat
        var barHeight: CGFloat {
            frameHeight - 40
        }
        
        var body: some View {
            VStack(spacing: 3) {
                Group {
                    if showNameOnTop {
                        // Name on top
                        Text(taskStat.todo.todo ?? "Unknown")
                            .font(FontTokens.architectsDaughter(size: 10))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .padding(.horizontal, -10)
                            .minimumScaleFactor(0.8)
                            .zIndex(2)
                            .opacity(taskStat.todo.isDeleted ? 0.5 : 1.0)
                    } else {
                        Color.clear
                    }
                }
                .frame(height: 10)
                
                
                // Bar
                RoundedRectangle(cornerRadius: 4)
                    .fill(getTaskColor(taskStat.time))
                    .frame(width: 15, height: min(barHeight, CGFloat(taskStat.time / 3600) / 12 * barHeight))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.black, lineWidth: 1)
                    )
                
                // Time
                Text("\(String(format: "%.1f", taskStat.time / 3600))hr")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(ColorTokens.shade600)
                
                Group {
                    if !showNameOnTop {
                        // Name on bottom
                        Text(taskStat.todo.todo ?? "Unknown")
                            .font(FontTokens.architectsDaughter(size: 10))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .padding(.horizontal, -10)
                            .zIndex(2)
                            .opacity(taskStat.todo.isDeleted ? 0.5 : 1.0)
                    } else {
                        Color.clear
                    }
                }
                .frame(height: 10)
            }
            .frame(maxWidth: .infinity)
        }
        
        private func getTaskColor(_ time: TimeInterval) -> Color {
            let hours = time / 3600
            if hours >= 2 {
                return ColorTokens.red300
            } else if hours >= 1 {
                return ColorTokens.red200
            } else {
                return ColorTokens.red100
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d yyyy"
        return formatter
    }
    
    private var safeGoals: [Goal] {
        allGoals.filter { !$0.isDeleted }
    }
    
    private func getTaskStats() -> [TaskStat] {
        var taskStats: [UUID?: TaskStat] = [:]
        
        for taskLog in taskLogs {
            guard let todo = taskLog.todo, !todo.isDeleted else { continue }
            guard let session = taskLog.session, !session.isDeleted else { continue }
            let todoID = todo.id
            
            if let existing = taskStats[todoID] {
                taskStats[todoID] = TaskStat(
                    todo: todo,
                    time: existing.time + taskLog.timeIn,
                    color: (todo.goal != nil && !todo.goal!.isDeleted) ? todo.goal?.realColor ?? existing.color : existing.color
                )
            } else {
                taskStats[todoID] = TaskStat(
                    todo: todo,
                    time: taskLog.timeIn,
                    color: (todo.goal != nil && !todo.goal!.isDeleted) ? todo.goal?.realColor ?? ColorTokens.red300 : ColorTokens.red300
                )
            }
        }
        
        return Array(taskStats.values).sorted { $0.time > $1.time }
    }
    
    private func getTaskColor(_ time: TimeInterval) -> Color {
        let hours = time / 3600
        if hours >= 2 {
            return ColorTokens.red300
        } else if hours >= 1 {
            return ColorTokens.red200
        } else {
            return ColorTokens.red100
        }
    }
}

struct TaskStat {
    let todo: Todo
    let time: TimeInterval
    let color: Color
}

// MARK: - Goal Progress View
struct GoalProgressView: View {
    let goal: Goal
    let date: Date
    
    @State var barWidth: CGFloat? = nil
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(goal.goal ?? "Unknown Goal")
                .font(FontTokens.architectsDaughter(size: 12))
                .foregroundColor(.black)
                .lineLimit(1)
                .opacity(goal.isDeleted ? 0.5 : 1.0)
            
            // Progress bar
            HStack {
                Image(uiImage: FormattedImages.Image163)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24, alignment: .trailing)
                    .offset(x: 5)
                    .zIndex(2)
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.black)
                        .frame(height: 24)
                        .background(
                            BGSizeReader(width: $barWidth)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(ColorTokens.red300)
                                .frame(width: progressWidth ?? 0, height: 24),
                            alignment: .leading
                        )
                    
                    HStack {
                        Spacer()
                        Text("\(Int(progressPercentage))%")
                            .font(FontTokens.architectsDaughter(size: 16))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white, lineWidth: 3)
                        .frame(height: 24)
                }
            }
        }
    }
    
    private var progressPercentage: Double {
        guard !goal.isDeleted else { return 0 }
        guard let progress = try? goal.getLatestProgress(before: date) else { return 0 }
        guard !progress.isDeleted else { return 0 }
        let current = progress.iqCurrent
        let goal = progress.iqGoal
        return goal > 0 ? (current / goal) * 100 : 0
    }
    
    private var progressWidth: CGFloat? {
        let percentage = progressPercentage / 100
        if let barWidth = barWidth {
            return max(0, min(1, percentage)) * barWidth
        }
        return nil
    }
}

// MARK: - Session Logs View (Group 192)
struct SessionLogsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch sessions
    @FetchRequest(
        entity: Session.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Session.started, ascending: false)]
    ) private var sessions: FetchedResults<Session>
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(sessions, id: \.id) { session in
                        if !session.isDeleted {
                            SessionLogRow(session: session)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
    }
}

struct SessionLogRow: View {
    let session: Session
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd h:mm a"
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }
    
    var formattedStart: String {
        guard !session.isDeleted else { return "Unknown Session" }
        if let start = session.started {
            return dateFormatter.string(from: start)
        } else {
            return "No Start Time"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            if !session.isDeleted && session.success {
                Image(uiImage: FormattedImages.Image163)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            } else {
                Image(uiImage: FormattedImages.Image164)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
            
            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text("\(formattedStart) - \(getTopTask(session)) [\(!session.isDeleted && session.success ? "SUCCESS" : "FAILED") \(String(format: "%.1f", !session.isDeleted ? session.timeLocked / 3600 : 0))hr]")
                    .font(FontTokens.architectsDaughter(size: 14))
                    .foregroundColor(.black)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .frame(height: 30)
    }
    
    private func getTopTask(_ session: Session) -> String {
        guard !session.isDeleted else { return "Unknown Task" }
        return session.topTaskLog?.todoTitle ?? "Unknown Task"
    }
}

struct BGSizeReader: View {
    private let width: Binding<CGFloat?>?
    private let height: Binding<CGFloat?
    >?
    
    init(width: Binding<CGFloat?>? = nil, height: Binding<CGFloat?>? = nil) {
        self.width = width
        self.height = height
    }
    
    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear {
                    width?.wrappedValue = proxy.size.width
                    height?.wrappedValue = proxy.size.height
                }
                .onChange(of: proxy.size.width) { val in
                    width?.wrappedValue = val
                }
                .onChange(of: proxy.size.height) { val in
                    height?.wrappedValue = val
                }
        }
    }
}

// MARK: - Sample Data Functions
func addSampleStatsData(viewContext: NSManagedObjectContext) {
    do {
        // Clear existing data
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Session.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let _ = try viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
        
        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Goal.fetchRequest()
        let batchDeleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        let _ = try viewContext.execute(batchDeleteRequest2) as? NSBatchDeleteResult
        
        let fetchRequest4: NSFetchRequest<NSFetchRequestResult> = TaskLog.fetchRequest()
        let batchDeleteRequest4 = NSBatchDeleteRequest(fetchRequest: fetchRequest4)
        let _ = try viewContext.execute(batchDeleteRequest4) as? NSBatchDeleteResult
        
        let fetchRequest5: NSFetchRequest<NSFetchRequestResult> = GoalProgress.fetchRequest()
        let batchDeleteRequest5 = NSBatchDeleteRequest(fetchRequest: fetchRequest5)
        let _ = try viewContext.execute(batchDeleteRequest5) as? NSBatchDeleteResult
        
        let fetchRequest3: NSFetchRequest<NSFetchRequestResult> = Todo.fetchRequest()
        let batchDeleteRequest3 = NSBatchDeleteRequest(fetchRequest: fetchRequest3)
        let _ = try viewContext.execute(batchDeleteRequest3) as? NSBatchDeleteResult
        
        try viewContext.save()
        print("Items deleted successfully")
        
        // Add sample goals
        let goal1 = Goal(context: viewContext)
        goal1.id = UUID()
        goal1.goal = "Finish this goddamn UI"
        goal1.created = Date()
        goal1.redeemed = false
        goal1.addProgress(iqCurrent: 34, iqGoal: 100)
        
        let goal2 = Goal(context: viewContext)
        goal2.id = UUID()
        goal2.goal = "Pass ECO exam"
        goal2.created = Date()
        goal2.redeemed = false
        goal2.addProgress(iqCurrent: 66, iqGoal: 100)
        
        let goal3 = Goal(context: viewContext)
        goal3.id = UUID()
        goal3.goal = "Learn SwiftUI"
        goal3.created = Date()
        goal3.redeemed = false
        goal3.addProgress(iqCurrent: 25, iqGoal: 50)
        
        try viewContext.save()
        print("Goals added successfully")
        
        // Add sample todos
        let todo1 = Todo(context: viewContext)
        todo1.id = UUID()
        todo1.todo = "Exercise"
        todo1.created = Date()
        todo1.goal = goal1
        
        let todo2 = Todo(context: viewContext)
        todo2.id = UUID()
        todo2.todo = "ECO220"
        todo2.created = Date()
        todo2.goal = goal2
        
        let todo3 = Todo(context: viewContext)
        todo3.id = UUID()
        todo3.todo = "Clean room"
        todo3.created = Date()
        todo3.goal = goal1
        
        try viewContext.save()
        print("Todos added successfully")
        
        // Add sample sessions for today
        let today = Date()
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: today)
        
        // Session 1 - Exercise
        let session1 = Session(context: viewContext)
        session1.id = UUID()
        session1.started = calendar.date(byAdding: .hour, value: 9, to: startOfToday)!
        session1.ended = calendar.date(byAdding: .hour, value: 10, to: startOfToday)!
        session1.timeLocked = 3600 // 1 hour
        session1.plannedTime = 3600
        session1.success = true
        
        let taskLog1 = TaskLog(context: viewContext)
        taskLog1.id = UUID()
        taskLog1.timeIn = 1800 // 30 minutes
        taskLog1.session = session1
        taskLog1.todo = todo1
        
        // Session 2 - ECO220
        let session2 = Session(context: viewContext)
        session2.id = UUID()
        session2.started = calendar.date(byAdding: .hour, value: 14, to: startOfToday)!
        session2.ended = calendar.date(byAdding: .hour, value: 16, to: startOfToday)!
        session2.timeLocked = 7200 // 2 hours
        session2.plannedTime = 7200
        session2.success = true
        
        try viewContext.save()
        print("Sessions added successfully")
        
        let taskLog2 = TaskLog(context: viewContext)
        taskLog2.id = UUID()
        taskLog2.timeIn = 12 * 3600 // 1.4 hours
        taskLog2.session = session2
        taskLog2.todo = todo3
        
        let taskLog3 = TaskLog(context: viewContext)
        taskLog3.id = UUID()
        taskLog3.timeIn = 2160 // 0.6 hours
        taskLog3.session = session2
        taskLog3.todo = todo2
        
        try viewContext.save()
        print("TaskLogs added successfully")

        print("Items added successfully")
    } catch {
        print("Failed to add sample stats data: \(error)")
    }
}

struct StatsSummaryView_Previews: PreviewProvider {
    struct Wrapper: View {
        @State var showPreview: Bool = false
        @Environment(\.managedObjectContext) var viewContext
        
        var body: some View {
            if !showPreview {
                StatsSummaryView()
                    .frame(height: 300)
                    .onAppear {
                        addSampleStatsData(viewContext: PersistenceController.shared.container.viewContext)
                    }
            } else {
                Color.clear
                    .onAppear {
                        addSampleStatsData(viewContext: viewContext)
                    }
            }
        }
    }
    
    static var previews: some View {
        Wrapper()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
