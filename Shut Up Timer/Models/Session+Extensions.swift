import Foundation
import CoreData
import Combine

// MARK: - Session Extensions
extension Session {
    
    static func getIQChange(lockedTime: TimeInterval, success: Bool) -> Double {
        return lockedTime / 3600 - (success ? 0 : 1)
    }
    
    /// Calculated IQ change based on session success and planned time
    var iqChange: Double {
        return Session.getIQChange(lockedTime: timeLocked, success: success)
    }
    
    /// Returns task logs sorted by time spent (descending) with their todo info
    var sortedCategories: [(todoID: UUID, time: TimeInterval)] {
        guard let taskLogsSet = taskLogs as? Set<TaskLog> else { return [] }
        
        // Group by todo UUID and sum time
        var categorySeconds: [UUID: TimeInterval] = [:]
        for taskLog in taskLogsSet {
            guard let todoID = taskLog.todo?.id else { continue }
            categorySeconds[todoID, default: 0] += taskLog.timeIn
        }
        
        // Convert to array and sort by time
        return categorySeconds.map { (todoID: $0.key, time: $0.value) }
            .sorted { $0.time > $1.time }
    }
    
    /// Total time spent across all task logs in this session
    var totalTaskTime: TimeInterval {
        guard let taskLogsSet = taskLogs as? Set<TaskLog> else { return 0 }
        return taskLogsSet.reduce(0) { $0 + $1.timeIn }
    }
    
    /// Returns an array of task logs sorted by time
    var taskLogsArray: [TaskLog] {
        guard let taskLogsSet = taskLogs as? Set<TaskLog> else { return [] }
        return Array(taskLogsSet).sorted { $0.timeIn > $1.timeIn }
    }
    
    /// Returns the top task
    var topTaskLog: TaskLog? {
        return taskLogsArray.first
    }
}

// MARK: - TaskLog Extensions
extension TaskLog {
    
    /// Convenience computed property to get the todo title
    var todoTitle: String {
        return todo?.todo ?? "Unknown Task"
    }
    
    /// Formatted time string for display
    var formattedTime: String {
        let hours = Int(timeIn) / 3600
        let minutes = Int(timeIn) % 3600 / 60
        let seconds = Int(timeIn) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

// MARK: - Efficient Core Data Query Extensions
extension Session {
    /// Efficiently calculate total IQ across all sessions using Core Data aggregation
    static func getTotalIQ(context: NSManagedObjectContext) -> Double {
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        
        do {
            let sessions = try context.fetch(request)
            return sessions.reduce(0.0) { $0 + $1.iqChange }
        } catch {
            print("Failed to fetch sessions for IQ calculation: \(error)")
            return 0.0
        }
    }
    
    /// Efficiently calculate total time locked using Core Data aggregation
    static func getTotalTimeLocked(context: NSManagedObjectContext) -> Int {
        let request: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: "Session")
        request.resultType = .dictionaryResultType
        
        let sumExpression = NSExpression(format: "sum:(timeLocked)")
        let sumDescription = NSExpressionDescription()
        sumDescription.name = "totalTime"
        sumDescription.expression = sumExpression
        sumDescription.expressionResultType = .doubleAttributeType
        
        request.propertiesToFetch = [sumDescription]
        
        do {
            let results = try context.fetch(request)
            if let result = results.first,
               let totalTime = result["totalTime"] as? Double {
                return Int(totalTime)
            }
        } catch {
            print("Failed to calculate total time locked: \(error)")
        }
        
        return 0
    }
    
    /// Efficiently get top categories using Core Data joins and aggregation
    static func getTopCategories(context: NSManagedObjectContext) -> [(todoID: UUID, seconds: Int)] {
        let request: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: "TaskLog")
        request.resultType = .dictionaryResultType
        
        // Group by todo ID and sum timeIn
        let todoExpression = NSExpression(forKeyPath: "todo.id")
        let todoDescription = NSExpressionDescription()
        todoDescription.name = "todoID"
        todoDescription.expression = todoExpression
        todoDescription.expressionResultType = .UUIDAttributeType
        
        let sumExpression = NSExpression(format: "sum:(timeIn)")
        let sumDescription = NSExpressionDescription()
        sumDescription.name = "totalTime"
        sumDescription.expression = sumExpression
        sumDescription.expressionResultType = .doubleAttributeType
        
        request.propertiesToFetch = [todoDescription, sumDescription]
        request.propertiesToGroupBy = [todoDescription]
        
        // Sort by total time descending
        request.sortDescriptors = [NSSortDescriptor(key: "totalTime", ascending: false)]
        
        do {
            let results = try context.fetch(request)
            return results.compactMap { result in
                guard let todoID = result["todoID"] as? UUID,
                      let totalTime = result["totalTime"] as? Double else {
                    return nil
                }
                return (todoID: todoID, seconds: Int(totalTime))
            }
        } catch {
            print("Failed to get top categories: \(error)")
            return []
        }
    }
    
    /// Get top category strings efficiently using joins
    static func getTopCategoryStrings(context: NSManagedObjectContext) -> [String] {
        let topCategories = getTopCategories(context: context)
        var categoryStrings: [String] = []
        
        // Batch fetch todos to avoid N+1 queries
        let todoIDs = topCategories.map { $0.todoID }
        let todoRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
        todoRequest.predicate = NSPredicate(format: "id IN %@", todoIDs)
        
        do {
            let todos = try context.fetch(todoRequest)
            let todoDict = Dictionary(uniqueKeysWithValues: todos.map { ($0.id!, $0.todo ?? "") })
            
            for category in topCategories {
                if let todoTitle = todoDict[category.todoID] {
                    categoryStrings.append(todoTitle)
                }
            }
        } catch {
            print("Failed to get category strings: \(error)")
        }
        
        return categoryStrings
    }
    
    /// Efficiently get date hours using Core Data aggregation
    static func getDateHours(context: NSManagedObjectContext) -> [Date: TimeInterval] {
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Session.started, ascending: true)]
        
        do {
            let sessions = try context.fetch(request)
            var dateHours: [Date: TimeInterval] = [:]
            
            for session in sessions {
                guard let started = session.started else { continue }
                let startOfDay = Calendar.current.startOfDay(for: started)
                dateHours[startOfDay, default: 0] += session.timeLocked
            }
            
            return dateHours
        } catch {
            print("Failed to get date hours: \(error)")
            return [:]
        }
    }
    
    /// Get latest roasts efficiently with sorting
    static func getLatestRoasts(context: NSManagedObjectContext) -> [String] {
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Session.started, ascending: false)]
        request.predicate = NSPredicate(format: "roast != nil")
        
        do {
            let sessions = try context.fetch(request)
            return sessions.compactMap { $0.roast }
        } catch {
            print("Failed to get latest roasts: \(error)")
            return []
        }
    }
    
    /// Fetch sessions from a specific date range
    static func fetchSessions(from startDate: Date, to endDate: Date, context: NSManagedObjectContext) -> [Session] {
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.predicate = NSPredicate(format: "started >= %@ AND started <= %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Session.started, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch sessions: \(error)")
            return []
        }
    }
    
    /// Fetch successful sessions only
    static func fetchSuccessfulSessions(context: NSManagedObjectContext) -> [Session] {
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.predicate = NSPredicate(format: "success == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Session.started, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch successful sessions: \(error)")
            return []
        }
    }
}

extension TaskLog {
    
    // @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskLog> {
    //     return NSFetchRequest<TaskLog>(entityName: "TaskLog")
    // }
    
    /// Fetch task logs for a specific todo
    static func fetchTaskLogs(for todo: Todo, context: NSManagedObjectContext) -> [TaskLog] {
        let request: NSFetchRequest<TaskLog> = TaskLog.fetchRequest()
        request.predicate = NSPredicate(format: "todo == %@", todo)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskLog.timeIn, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch task logs: \(error)")
            return []
        }
    }
} 
