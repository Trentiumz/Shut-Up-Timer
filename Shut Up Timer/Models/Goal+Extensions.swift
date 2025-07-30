import SwiftUI
import CoreData

extension Goal {
    var realColor: Color? {
        if let gColor = self.color {
            return hexStringToColor(gColor)
        }
        return nil
    }
    
    func addProgress(iqCurrent: Double, iqGoal: Double, date: Date = Date()) {
        if let managedObjectContext = self.managedObjectContext {
            let goalProgress = GoalProgress(context: managedObjectContext)
            goalProgress.iqCurrent = iqCurrent
            goalProgress.iqGoal = iqGoal
            goalProgress.date = date
            goalProgress.goal = self
        }
    }
    
    /// Add a new progress point. Make sure that at most one of iqCurrentChange and iqCurrent are set
    func updateProgress(iqCurrentChange: Double? = nil, iqCurrent: Double? = nil, iqGoal: Double? = nil, date: Date = Date()) {
        if let managedObjectContext = self.managedObjectContext {
            let lastGoalProgress = self.lastGoalProgress
            let goalProgress = GoalProgress(context: managedObjectContext)
            
            let lastCurrent = lastGoalProgress?.iqCurrent ?? 0
            if let iqCurrentChange = iqCurrentChange {
                goalProgress.iqCurrent = lastCurrent + iqCurrentChange
            } else {
                goalProgress.iqCurrent = iqCurrent ?? lastGoalProgress?.iqCurrent ?? 0
            }
            goalProgress.iqGoal = iqGoal ?? lastGoalProgress?.iqGoal ?? 0
            goalProgress.date = date
            goalProgress.goal = self
        }
    }
    
    func getLatestProgress(before: Date? = nil) throws -> GoalProgress? {
        let fetchRequest = GoalProgress.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        if let before = before {
            fetchRequest.predicate = NSPredicate(format: "goal == %@ AND date <= %@", self, before as NSDate)
        } else {
            fetchRequest.predicate = NSPredicate(format: "goal == %@", self)
        }
        fetchRequest.fetchLimit = 1
        
        let results = try self.managedObjectContext?.fetch(fetchRequest)
        return results?.first
    }
    
    var lastGoalProgress: GoalProgress? {
        self.goalProgress?.reduce(nil as GoalProgress?, {cur, nex in
            if let nex = nex as? GoalProgress {
                if let cur = cur, let curDate = cur.date {
                    if let nexDate = nex.date {
                        return curDate < nexDate ? nex : cur
                    }
                    return cur
                }
                return nex
            }
            return nil
        })
    }
}
