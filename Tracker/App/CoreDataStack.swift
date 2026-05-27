import CoreData

final class CoreDataStack {


    lazy var persistentContainer: NSPersistentContainer = {
        WeekDayTransformer.register()
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Core Data failed to load: \(error)")
            }
        }
        return container
    }()


    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            assertionFailure("Failed to save context: \(error)")
        }
    }
}
