import Foundation
import CoreData
import Combine

// MARK: - Backward Compatibility Structs

struct TempTaskLog: Identifiable, Codable, Equatable {
    var id = UUID()
    var todoID: UUID
    var timeIn: TimeInterval
}

struct TempSession: Identifiable, Codable, Equatable {
    var id = UUID()
    var tasks: [TempTaskLog]
    var started: Date
    var ended: Date
    var timeLocked: TimeInterval
    var plannedTime: TimeInterval
    var success: Bool
    var roast: String?
    var imageName: String?
    
    var iqChange: Double {
        Session.getIQChange(lockedTime: timeLocked, success: success)
    }
    
    var sortedCategories: [(todoID: UUID, time: TimeInterval)] {
        // Create a dictionary to store total seconds per todoID
        var categorySeconds: [UUID: TimeInterval] = [:]
        
        // Calculate total seconds for each todoID
        for taskLog in self.tasks {
            let seconds = taskLog.timeIn
            categorySeconds[taskLog.todoID, default: 0] += seconds
        }
        
        // Convert dictionary to array of tuples and sort by seconds
        let sortedCategories = categorySeconds.map { (todoID: $0.key, time: $0.value) }
            .sorted { $0.time > $1.time }
        
        return sortedCategories
    }
}

// MARK: - Sessions Wrapper

/// Wrapper class that provides utility methods for Session Core Data operations
class SessionLoader : ObservableObject {
    let didChange = PassthroughSubject<Void, Never>()
    var cancellables = Set<AnyCancellable>()
    
    private let persistenceController = PersistenceController.shared
    private var context: NSManagedObjectContext {
        return persistenceController.container.viewContext
    }
    
    init() {
        // Listen for Core Data changes and notify subscribers
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(managedObjectContextDidSave),
            name: .NSManagedObjectContextDidSave,
            object: context
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func managedObjectContextDidSave(notification: NSNotification) {
        // Only trigger notification if Session entities were changed
        guard let userInfo = notification.userInfo else { return }
        
        let changedObjects = [
            userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> ?? Set(),
            userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> ?? Set(),
            userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> ?? Set()
        ].flatMap { $0 }
        
        let sessionChanged = changedObjects.contains { object in
            return object is Session || object is TaskLog
        }
        
        if sessionChanged {
            DispatchQueue.main.async {
                self.didChange.send()
            }
        }
    }
    
    // MARK: - Core Data Operations
    
    /// Add a new session to Core Data using TempSession
    func addSession(_ tempSession: TempSession) {
        let session = Session(context: context)
        session.id = tempSession.id
        session.started = tempSession.started
        session.ended = tempSession.ended
        session.timeLocked = tempSession.timeLocked
        session.plannedTime = tempSession.plannedTime
        session.success = tempSession.success
        session.roast = tempSession.roast
        session.imageName = tempSession.imageName
        
        var goalChanges: [Goal: Double] = [:]
        // Add task logs
        for taskData in tempSession.tasks {
            addTaskLog(to: session, todoID: taskData.todoID, timeIn: taskData.timeIn, taskLogID: taskData.id, goalChanges: &goalChanges)
        }
        for (goal, change) in goalChanges {
            goal.updateProgress(iqCurrentChange: change)
        }
        
        saveContext()
    }
    
    /// Add a task log to a session
    private func addTaskLog(to session: Session, todoID: UUID, timeIn: TimeInterval, taskLogID: UUID, goalChanges: inout [Goal: Double]) {
        // Find the Todo entity by ID
        let todoRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
        todoRequest.predicate = NSPredicate(format: "id == %@", todoID as CVarArg)
        
        do {
            let todos = try context.fetch(todoRequest)
            guard let todo = todos.first else {
                print("Todo not found for ID: \(todoID)")
                return
            }
            
            let taskLog = TaskLog(context: context)
            taskLog.id = taskLogID
            taskLog.timeIn = timeIn
            taskLog.session = session
            taskLog.todo = todo
            
            if let goal = todo.goal {
                goalChanges[goal, default: 0] += Session.getIQChange(lockedTime: timeIn, success: true)
            }
        } catch {
            print("Failed to create task log: \(error)")
        }
    }
    
    /// Delete a session from Core Data
    func deleteSession(_ session: Session) {
        context.delete(session)
        saveContext()
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
                context.reset()
            }
        }
    }
} 
