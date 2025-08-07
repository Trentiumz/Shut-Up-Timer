import CoreData

extension RoastGenerator {
    class RoastFeatureGenerator {
        var viewContext: NSManagedObjectContext
        init(viewContext: NSManagedObjectContext) {
            self.viewContext = viewContext
        }
        
        func generateFeatures() -> [String] {
            var features: [String] = []
            
            // Note: Funny task detection and interpretation is left to the server/LLM
            // to handle more intelligently based on context and user preferences
            
            // Add basic user structure info
            features.append(contentsOf: getUserStructureInfo())
            
            // Add recent performance patterns
            features.append(contentsOf: getRecentPerformanceFeatures())
            
            // Add task-specific features
            features.append(contentsOf: getTaskSpecificFeatures())
            
            // Add goal-related features
            features.append(contentsOf: getGoalRelatedFeatures())
            
            // Add behavioral patterns
            features.append(contentsOf: getBehavioralPatternFeatures())
            
            // Add session-specific quirks
            features.append(contentsOf: getSessionQuirkFeatures())
            
            return features
        }
        
        // MARK: - User Structure Info
        
        private func getUserStructureInfo() -> [String] {
            var features: [String] = []
            
            // Get all active goals and their tasks
            let goalRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
            goalRequest.predicate = NSPredicate(format: "active == YES")
            goalRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Goal.order, ascending: true)]
            
            do {
                let goals = try viewContext.fetch(goalRequest)
                var goalTaskStructure: [String] = []
                
                for goal in goals {
                    let goalName = goal.goal ?? "Unknown Goal"
                    let tasks = goal.tasks?.allObjects as? [Todo] ?? []
                    let taskNames = tasks.compactMap { $0.todo }.joined(separator: ", ")
                    goalTaskStructure.append("Goal: \(goalName) - Tasks: \(taskNames)")
                }
                
                if !goalTaskStructure.isEmpty {
                    features.append("User Goals and Tasks: \(goalTaskStructure.joined(separator: " | "))")
                }
            } catch {
                print("Failed to fetch goals: \(error)")
            }
            
            return features
        }
        
        // MARK: - Recent Performance Features
        
        private func getRecentPerformanceFeatures() -> [String] {
            var features: [String] = []
            
            let calendar = Calendar.current
            let now = Date()
            
            // Get sessions from last 7 days
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            let weekSessions = fetchSessions(from: weekAgo, to: now)
            
            // Get sessions from last 2 days
            let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now) ?? now
            let recentSessions = fetchSessions(from: twoDaysAgo, to: now)
            
            // Get yesterday's sessions
            let yesterday = calendar.date(byAdding: .day, value: -1, to: now) ?? now
            let yesterdayStart = calendar.startOfDay(for: yesterday)
            let yesterdayEnd = calendar.date(byAdding: .day, value: 1, to: yesterdayStart) ?? yesterday
            let yesterdaySessions = fetchSessions(from: yesterdayStart, to: yesterdayEnd)
            
            // Recent vs past week comparison
            if !weekSessions.isEmpty && !recentSessions.isEmpty {
                let weekAvg = weekSessions.map { $0.timeLocked }.reduce(0, +) / Double(weekSessions.count)
                let recentAvg = recentSessions.map { $0.timeLocked }.reduce(0, +) / Double(recentSessions.count)
                
                let percentageChange = ((recentAvg - weekAvg) / weekAvg) * 100
                if percentageChange < -20 {
                    features.append("Recent performance \(String(format: "%.1f", abs(percentageChange)))% below weekly average")
                } else if percentageChange > 20 {
                    features.append("Recent performance \(String(format: "%.1f", percentageChange))% above weekly average")
                }
            }
            
            // Yesterday's performance
            if !yesterdaySessions.isEmpty {
                let yesterdayTotal = yesterdaySessions.map { $0.timeLocked }.reduce(0, +)
                let yesterdayHours = yesterdayTotal / 3600
                
                if yesterdayHours < 1 {
                    features.append("Yesterday only studied \(String(format: "%.1f", yesterdayHours)) hours")
                } else if yesterdayHours > 8 {
                    features.append("Yesterday studied \(String(format: "%.1f", yesterdayHours)) hours - overachiever")
                }
                
                // Check for failed sessions yesterday
                let failedYesterday = yesterdaySessions.filter { !$0.success }
                if !failedYesterday.isEmpty {
                    features.append("Failed \(failedYesterday.count) sessions yesterday")
                }
            }
            
            // Success rate trends
            let recentSuccessRate = Double(recentSessions.filter { $0.success }.count) / Double(recentSessions.count)
            let weekSuccessRate = Double(weekSessions.filter { $0.success }.count) / Double(weekSessions.count)
            
            if weekSuccessRate > 0 {
                let successRateChange = ((recentSuccessRate - weekSuccessRate) / weekSuccessRate) * 100
                if successRateChange < -20 {
                    features.append("Recent success rate dropped \(String(format: "%.1f", abs(successRateChange)))% from weekly average")
                }
            }
            
            return features
        }
        
        // MARK: - Task Specific Features
        
        private func getTaskSpecificFeatures() -> [String] {
            var features: [String] = []
            
            // Get all tasks with their usage stats
            let todoRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
            todoRequest.predicate = NSPredicate(format: "active == YES")
            
            do {
                let todos = try viewContext.fetch(todoRequest)
                var taskUsage: [String: (totalTime: TimeInterval, sessionCount: Int, lastUsed: Date?)] = [:]
                
                // Get all task logs for these todos
                let taskLogRequest: NSFetchRequest<TaskLog> = TaskLog.fetchRequest()
                taskLogRequest.predicate = NSPredicate(format: "todo IN %@", todos)
                
                let taskLogs = try viewContext.fetch(taskLogRequest)
                
                for taskLog in taskLogs {
                    guard let todoName = taskLog.todo?.todo else { continue }
                    let current = taskUsage[todoName] ?? (0, 0, nil)
                    taskUsage[todoName] = (
                        totalTime: current.totalTime + taskLog.timeIn,
                        sessionCount: current.sessionCount + 1,
                        lastUsed: max(current.lastUsed ?? Date.distantPast, taskLog.session?.started ?? Date.distantPast)
                    )
                }
                
                // Find least used tasks
                let sortedTasks = taskUsage.sorted { $0.value.totalTime < $1.value.totalTime }
                if let leastUsed = sortedTasks.first {
                    let hours = leastUsed.value.totalTime / 3600
                    features.append("Least used task: '\(leastUsed.key)' - only \(String(format: "%.1f", hours)) hours total")
                }
                
                // Find most used tasks
                if let mostUsed = sortedTasks.last {
                    let hours = mostUsed.value.totalTime / 3600
                    features.append("Most used task: '\(mostUsed.key)' - \(String(format: "%.1f", hours)) hours total")
                }
                
                // Find tasks not used recently
                let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
                let oldTasks = taskUsage.filter { $0.value.lastUsed ?? Date.distantPast < twoWeeksAgo }
                if let oldestTask = oldTasks.sorted(by: { $0.value.lastUsed ?? Date.distantPast < $1.value.lastUsed ?? Date.distantPast }).first {
                    features.append("Haven't touched '\(oldestTask.key)' in over 2 weeks")
                }
                
                // Note: Task name interpretation and humor detection is left to the server/LLM
                // to handle more intelligently based on context and user preferences
                
            } catch {
                print("Failed to fetch task data: \(error)")
            }
            
            return features
        }
        
        // MARK: - Goal Related Features
        
        private func getGoalRelatedFeatures() -> [String] {
            var features: [String] = []
            
            let goalRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
            goalRequest.predicate = NSPredicate(format: "active == YES")
            
            do {
                let goals = try viewContext.fetch(goalRequest)
                
                for goal in goals {
                    guard let goalName = goal.goal else { continue }
                    
                    // Check if goal has any progress
                    let progressRequest: NSFetchRequest<GoalProgress> = GoalProgress.fetchRequest()
                    progressRequest.predicate = NSPredicate(format: "goal == %@", goal)
                    progressRequest.sortDescriptors = [NSSortDescriptor(keyPath: \GoalProgress.date, ascending: false)]
                    progressRequest.fetchLimit = 1
                    
                    let recentProgress = try viewContext.fetch(progressRequest).first
                    
                    if let progress = recentProgress {
                        let progressPercentage = (progress.iqCurrent / progress.iqGoal) * 100
                        if progressPercentage < 10 {
                            features.append("Goal '\(goalName)' only \(String(format: "%.1f", progressPercentage))% complete")
                        } else if progressPercentage > 90 {
                            features.append("Goal '\(goalName)' almost complete at \(String(format: "%.1f", progressPercentage))%")
                        }
                    } else {
                        features.append("Goal '\(goalName)' has no progress recorded")
                    }
                    
                    // Check if goal has tasks
                    let tasks = goal.tasks?.allObjects as? [Todo] ?? []
                    if tasks.isEmpty {
                        features.append("Goal '\(goalName)' has no tasks assigned")
                    }
                }
                
            } catch {
                print("Failed to fetch goal data: \(error)")
            }
            
            return features
        }
        
        // MARK: - Behavioral Pattern Features
        
        private func getBehavioralPatternFeatures() -> [String] {
            var features: [String] = []
            
            // Get recent sessions for pattern analysis
            let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
            let recentSessions = fetchSessions(from: twoWeeksAgo, to: Date())
            
            if !recentSessions.isEmpty {
                // Check for short sessions (potential procrastination)
                let shortSessions = recentSessions.filter { $0.timeLocked < 300 } // Less than 5 minutes
                if !recentSessions.isEmpty {
                    let shortSessionPercentage = (Double(shortSessions.count) / Double(recentSessions.count)) * 100
                    if shortSessionPercentage > 20 {
                        features.append("\(String(format: "%.1f", shortSessionPercentage))% of recent sessions were under 5 minutes")
                    }
                }
                
                // Check for very long sessions
                let longSessions = recentSessions.filter { $0.timeLocked > 7200 } // More than 2 hours
                if !longSessions.isEmpty {
                    features.append("Has \(longSessions.count) marathon sessions over 2 hours")
                }
                
                // Check for time of day patterns
                let morningSessions = recentSessions.filter { session in
                    guard let started = session.started else { return false }
                    let hour = Calendar.current.component(.hour, from: started)
                    return hour >= 6 && hour < 12
                }
                
                let nightSessions = recentSessions.filter { session in
                    guard let started = session.started else { return false }
                    let hour = Calendar.current.component(.hour, from: started)
                    return hour >= 22 || hour < 6
                }
                
                if !morningSessions.isEmpty && !nightSessions.isEmpty {
                    let nightToMorningRatio = Double(nightSessions.count) / Double(morningSessions.count)
                    if nightToMorningRatio > 2 {
                        features.append("Studies \(String(format: "%.1f", nightToMorningRatio))x more at night than in the morning")
                    }
                }
                
                // Check for weekend vs weekday patterns
                let weekdaySessions = recentSessions.filter { session in
                    guard let started = session.started else { return false }
                    let weekday = Calendar.current.component(.weekday, from: started)
                    return weekday >= 2 && weekday <= 6 // Monday to Friday
                }
                
                let weekendSessions = recentSessions.filter { session in
                    guard let started = session.started else { return false }
                    let weekday = Calendar.current.component(.weekday, from: started)
                    return weekday == 1 || weekday == 7 // Sunday or Saturday
                }
                
                if !weekdaySessions.isEmpty && !weekendSessions.isEmpty {
                    let weekendToWeekdayRatio = Double(weekendSessions.count) / Double(weekdaySessions.count)
                    if weekendToWeekdayRatio > 1.2 {
                        features.append("Studies \(String(format: "%.1f", weekendToWeekdayRatio))x more on weekends than weekdays")
                    }
                }
            }
            
            return features
        }
        
        // MARK: - Session Quirk Features
        
        private func getSessionQuirkFeatures() -> [String] {
            var features: [String] = []
            
            // Get recent sessions
            let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            let recentSessions = fetchSessions(from: oneWeekAgo, to: Date())
            
            if !recentSessions.isEmpty {
                // Check for sessions with many task switches
                let sessionsWithManyTasks = recentSessions.filter { session in
                    let taskLogs = session.taskLogsArray
                    return taskLogs.count > 5
                }
                
                if !sessionsWithManyTasks.isEmpty {
                    features.append("Has sessions with 5+ different tasks - can't focus")
                }
                
                // Check for sessions with very short task times
                let sessionsWithShortTasks = recentSessions.filter { session in
                    let taskLogs = session.taskLogsArray
                    return taskLogs.contains { $0.timeIn < 60 } // Less than 1 minute per task
                }
                
                if !sessionsWithShortTasks.isEmpty {
                    features.append("Has sessions with tasks under 1 minute - attention span issues")
                }
                
                // Check for failed sessions with long planned times
                let failedLongSessions = recentSessions.filter { session in
                    !session.success && session.plannedTime > 3600 // Planned over 1 hour but failed
                }
                
                if !failedLongSessions.isEmpty {
                    features.append("Failed \(failedLongSessions.count) sessions that were planned for over 1 hour")
                }
                
                // Check for sessions with no task logs (weird sessions)
                let emptySessions = recentSessions.filter { session in
                    session.taskLogsArray.isEmpty
                }
                
                if !emptySessions.isEmpty {
                    features.append("Has \(emptySessions.count) sessions with no tasks recorded")
                }
            }
            
            return features
        }
        
        // MARK: - Helper Methods
        
        private func fetchSessions(from startDate: Date, to endDate: Date) -> [Session] {
            let request: NSFetchRequest<Session> = Session.fetchRequest()
            request.predicate = NSPredicate(format: "started >= %@ AND started <= %@", startDate as NSDate, endDate as NSDate)
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
