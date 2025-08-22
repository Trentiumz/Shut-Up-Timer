import CoreData

extension RoastGenerator {
    struct RoastInformation: Encodable {
        let mostCommonStudyHour: Int // timezone independent, w.r.t. UTC
        let totalStudyTime: TimeInterval
        let averageSessionLength: TimeInterval
        let successRate: Double
        let totalSessions: Int
        let longestSession: TimeInterval
        let activeTasksCount: Int
        let mostUsedTask: MostUsedTask?
        let activeGoalsCount: Int
        let goalProgress: [GoalProgress]
        let sessionsThisWeek: Int
        let preferredStudyTime: String?
        
        // Custom encoding to match Python backend structure
        enum CodingKeys: String, CodingKey {
            case mostCommonStudyHour = "most_common_study_hour"
            case totalStudyTime = "total_study_time"
            case averageSessionLength = "average_session_length"
            case successRate = "success_rate"
            case totalSessions = "total_sessions"
            case longestSession = "longest_session"
            case activeTasksCount = "active_tasks_count"
            case mostUsedTask = "most_used_task"
            case activeGoalsCount = "active_goals_count"
            case goalProgress = "goal_progress"
            case sessionsThisWeek = "sessions_this_week"
            case preferredStudyTime = "preferred_study_time"
        }
        
        struct MostUsedTask: Encodable {
            let name: String
            let time: TimeInterval // TimeInterval equivalent in seconds
            
            enum CodingKeys: String, CodingKey {
                case name
                case time
            }
        }
        
        struct GoalProgress: Encodable {
            let name: String
            let percentage: Double
            
            enum CodingKeys: String, CodingKey {
                case name
                case percentage
            }
        }
    }
    
    class RoastInformationGenerator {
        var viewContext: NSManagedObjectContext
        init(viewContext: NSManagedObjectContext) {
            self.viewContext = viewContext
        }
        
        func generateInformation() -> RoastInformation {
            return RoastInformation(
                mostCommonStudyHour: findMostCommonStudyHour(),
                totalStudyTime: getTotalStudyTime(),
                averageSessionLength: getAverageSessionLength(),
                successRate: getSuccessRate(),
                totalSessions: getTotalSessions(),
                longestSession: getLongestSession(),
                activeTasksCount: getActiveTasksCount(),
                mostUsedTask: getMostUsedTask(),
                activeGoalsCount: getActiveGoalsCount(),
                goalProgress: getGoalProgress(),
                sessionsThisWeek: getSessionsThisWeek(),
                preferredStudyTime: getPreferredStudyTime()
            )
        }
        
        // MARK: - Most Common Study Time (with Exponential Decay)
        
        private func findMostCommonStudyHour() -> Int {
            let sessions = fetchAllSessions()
            guard !sessions.isEmpty else {
                // Default to 6:00 PM local time translated to UTC
                return getDefaultStudyHour()
            }
            
            var hourWeights: [Int: Double] = [:]
            let now = Date()
            
            // Find the most recent session to calculate relative time
            let mostRecentSession = sessions.min { $0.started ?? Date.distantPast > $1.started ?? Date.distantPast }
            guard let lastSessionTime = mostRecentSession?.started else { return getDefaultStudyHour() }
            
            let totalDaysSinceLastSession = Calendar.current.dateComponents([.day], from: lastSessionTime, to: now).day ?? 1
            let halfLifeDays = max(1, totalDaysSinceLastSession / 2) // Adaptive half-life
            
            for session in sessions {
                guard let started = session.started else { continue }
                
                let hour = getTimezoneIndependentHour(from: started)
                let daysAgo = Calendar.current.dateComponents([.day], from: started, to: now).day ?? 0
                
                // Exponential decay: more recent sessions have higher weight
                // Half-life adapts to user's activity pattern
                let decayFactor = exp(-Double(daysAgo) / Double(halfLifeDays))
                let sessionWeight = session.timeLocked * decayFactor
                
                hourWeights[hour, default: 0] += sessionWeight
            }
            
            // Find hour with highest weighted score
            return hourWeights.max(by: { $0.value < $1.value })?.key ?? getDefaultStudyHour()
        }
        
        // MARK: - Timezone Independent Hour Calculation
        
        private func getTimezoneIndependentHour(from date: Date) -> Int {
            // Convert to UTC to ensurvarimezone independence
            var utcCalendar = Calendar.current
            utcCalendar.timeZone = TimeZone(abbreviation: "UTC")!
            
            let utcComponents = utcCalendar.dateComponents([.hour], from: date)
            return utcComponents.hour ?? 0
        }
        
        private func getDefaultStudyHour() -> Int {
            // Create a date representing 6:00 PM today in local time
            let calendar = Calendar.current
            let now = Date()
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.hour = 18 // 6:00 PM
            components.minute = 0
            components.second = 0
            
            guard let localSixPM = calendar.date(from: components) else {
                return 18 // Fallback to 6 PM UTC if conversion fails
            }
            
            // Convert to UTC
            return getTimezoneIndependentHour(from: localSixPM)
        }
        
        // MARK: - Individual Data Methods
        
        private func getTotalStudyTime() -> TimeInterval {
            return Session.getTotalTimeLocked(context: viewContext)
        }
        
        private func getAverageSessionLength() -> TimeInterval {
            let sessions = fetchAllSessions()
            guard !sessions.isEmpty else { return 0 }
            return sessions.map { $0.timeLocked }.reduce(0, +) / Double(sessions.count)
        }
        
        private func getSuccessRate() -> Double {
            let sessions = fetchAllSessions()
            guard !sessions.isEmpty else { return 0 }
            let successfulSessions = sessions.filter { $0.success }
            return Double(successfulSessions.count) / Double(sessions.count) * 100
        }
        
        private func getTotalSessions() -> Int {
            return fetchAllSessions().count
        }
        
        private func getLongestSession() -> TimeInterval {
            let sessions = fetchAllSessions()
            return sessions.max(by: { $0.timeLocked < $1.timeLocked })?.timeLocked ?? 0
        }
        
        private func getActiveTasksCount() -> Int {
            let request: NSFetchRequest<Todo> = Todo.fetchRequest()
            request.predicate = NSPredicate(format: "active == YES")
            
            do {
                return try viewContext.fetch(request).count
            } catch {
                print("Failed to fetch active tasks count: \(error)")
                return 0
            }
        }
        
        private func getMostUsedTask() -> RoastInformation.MostUsedTask? {
            do {
                var taskUsage: [String: TimeInterval] = [:]
                let taskLogRequest: NSFetchRequest<TaskLog> = TaskLog.fetchRequest()
                let taskLogs = try viewContext.fetch(taskLogRequest)
                
                for taskLog in taskLogs {
                    guard let todoName = taskLog.todo?.todo else { continue }
                    taskUsage[todoName, default: 0] += taskLog.timeIn
                }
                
                if let mostUsedTask = taskUsage.max(by: { $0.value < $1.value }) {
                    return RoastInformation.MostUsedTask(name: mostUsedTask.key, time: mostUsedTask.value)
                }
            } catch {
                print("Failed to fetch most used task: \(error)")
            }
            
            return nil
        }
        
        private func getActiveGoalsCount() -> Int {
            let request: NSFetchRequest<Goal> = Goal.fetchRequest()
            request.predicate = NSPredicate(format: "active == YES")
            
            do {
                return try viewContext.fetch(request).count
            } catch {
                print("Failed to fetch active goals count: \(error)")
                return 0
            }
        }
        
        private func getGoalProgress() -> [RoastInformation.GoalProgress] {
            let goalRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
            goalRequest.predicate = NSPredicate(format: "active == YES")
            
            var progress: [RoastInformation.GoalProgress] = []
            
            do {
                let goals = try viewContext.fetch(goalRequest)
                
                for goal in goals {
                    guard let goalName = goal.goal else { continue }
                    
                    let progressRequest = GoalProgress.fetchRequest()
                    progressRequest.predicate = NSPredicate(format: "goal == %@", goal)
                    progressRequest.sortDescriptors = [NSSortDescriptor(keyPath: \GoalProgress.date, ascending: false)]
                    progressRequest.fetchLimit = 1
                    
                    if let recentProgress = try viewContext.fetch(progressRequest).first {
                        let progressPercentage = (recentProgress.iqCurrent / recentProgress.iqGoal) * 100
                        progress.append(RoastInformation.GoalProgress(name: goalName, percentage: progressPercentage))
                    }
                }
                
            } catch {
                print("Failed to fetch goal progress: \(error)")
            }
            
            return progress
        }
        
        private func getSessionsThisWeek() -> Int {
            let sessions = fetchAllSessions()
            let calendar = Calendar.current
            let now = Date()
            let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return sessions.filter { $0.started ?? Date.distantPast >= oneWeekAgo }.count
        }
        
        private func getPreferredStudyTime() -> String? {
            let sessions = fetchAllSessions()
            guard !sessions.isEmpty else { return nil }
            
            let morningSessions = sessions.filter { session in
                guard let started = session.started else { return false }
                let hour = getTimezoneIndependentHour(from: started)
                return hour >= 6 && hour < 12
            }
            
            let afternoonSessions = sessions.filter { session in
                guard let started = session.started else { return false }
                let hour = getTimezoneIndependentHour(from: started)
                return hour >= 12 && hour < 18
            }
            
            let eveningSessions = sessions.filter { session in
                guard let started = session.started else { return false }
                let hour = getTimezoneIndependentHour(from: started)
                return hour >= 18 && hour < 22
            }
            
            let nightSessions = sessions.filter { session in
                guard let started = session.started else { return false }
                let hour = getTimezoneIndependentHour(from: started)
                return hour >= 22 || hour < 6
            }
            
            let timePreferences = [
                ("morning", morningSessions.count),
                ("afternoon", afternoonSessions.count),
                ("evening", eveningSessions.count),
                ("night", nightSessions.count)
            ].sorted { $0.1 > $1.1 }
            
            return timePreferences.first?.0
        }
        
        // MARK: - Helper Methods
        
        private func fetchAllSessions() -> [Session] {
            viewContext.performAndWait {
                let request: NSFetchRequest<Session> = Session.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(keyPath: \Session.started, ascending: false)]
                request.fetchLimit = 500 // Limit to 500 as requested
                
                do {
                    return try viewContext.fetch(request)
                } catch {
                    print("Failed to fetch sessions: \(error)")
                    return []
                }
            }
        }
    }
}
