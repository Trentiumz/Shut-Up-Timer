import CoreData

extension RoastGenerator {
    static func generateCatchphrase(viewContext: NSManagedObjectContext, credManager: CredManager) async -> String? {
        let featureGenerator = RoastGenerator.RoastFeatureGenerator(viewContext: viewContext)
        do {
            let newRoast = try await credManager.fastAPI.generateCatchphrase(roastFeatures: featureGenerator.generateFeatures())
            if let newRoast = newRoast {
                // Save to Core Data
                saveRoastToCoreData(viewContext: viewContext, content: newRoast, type: RoastType.catchphrase.rawValue)
                return newRoast
            }
            return nil
        } catch {
            print("Error generating new roast: \(error)")
            return nil
        }
    }
    
    static func generateRoast(viewContext: NSManagedObjectContext, credManager: CredManager) async -> String? {
        let featureGenerator = RoastGenerator.RoastFeatureGenerator(viewContext: viewContext)
        do {
            let newRoast = try await credManager.fastAPI.generateRoast(roastFeatures: featureGenerator.generateFeatures())
            if let newRoast = newRoast {
                // Save to Core Data
                saveRoastToCoreData(viewContext: viewContext, content: newRoast, type: RoastType.roast.rawValue)
                return newRoast
            }
            return nil
        } catch {
            print("Error generating new roast: \(error)")
            return nil
        }
    }
    
    private static func saveRoastToCoreData(viewContext: NSManagedObjectContext, content: String, type: String) {
        let pastRoast = PastRoasts(context: viewContext)
        pastRoast.content = content
        pastRoast.time = Date()
        pastRoast.type = type
        
        do {
            try viewContext.save()
            print("Saved \(type) to Core Data: \(content)")
        } catch {
            print("Failed to save \(type) to Core Data: \(error)")
        }
    }
    
    static func getLastRoast(type: RoastType, viewContext: NSManagedObjectContext) -> PastRoasts? {
        let request: NSFetchRequest<PastRoasts> = PastRoasts.fetchRequest()
        request.predicate = NSPredicate(format: "type == %@", type.rawValue)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PastRoasts.time, ascending: false)]
        request.fetchLimit = 1
        
        do {
            let roasts = try viewContext.fetch(request)
            return roasts.first
        } catch {
            print("Failed to fetch last roast: \(error)")
            return nil
        }
    }
    
    static func getRecentRoasts(type: RoastType, count: Int, viewContext: NSManagedObjectContext) -> [PastRoasts] {
        let request: NSFetchRequest<PastRoasts> = PastRoasts.fetchRequest()
        request.predicate = NSPredicate(format: "type == %@", type.rawValue)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PastRoasts.time, ascending: false)]
        request.fetchLimit = count
        
        do {
            let roasts = try viewContext.fetch(request)
            return roasts
        } catch {
            print("Failed to fetch recent roasts: \(error)")
            return []
        }
    }
}
