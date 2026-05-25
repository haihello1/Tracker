import CoreData

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>

    var onDataChanged: (() -> Void)?

    init(context: NSManagedObjectContext) {
        self.context = context

        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        super.init()

        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
    }

    func addCategory(title: String) throws -> TrackerCategoryCoreData {
        let entity = TrackerCategoryCoreData(context: context)
        entity.title = title
        try context.save()
        return entity
    }

    func findOrCreate(title: String) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        if let existing = try context.fetch(request).first {
            return existing
        }
        return try addCategory(title: title)
    }

    var categories: [TrackerCategory] {
        (fetchedResultsController.fetchedObjects ?? [])
            .compactMap { makeCategory(from: $0) }
    }

    private func makeCategory(from entity: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let title = entity.title else { return nil }
        let trackers = (entity.trackers?.allObjects as? [TrackerCoreData] ?? [])
            .compactMap { makeTracker(from: $0) }
        return TrackerCategory(title: title, trackerCollection: trackers)
    }

    private func makeTracker(from entity: TrackerCoreData) -> Tracker? {
        guard
            let id = entity.id,
            let name = entity.name,
            let colorRaw = entity.color,
            let color = TrackerColor(rawValue: colorRaw),
            let emoji = entity.emoji,
            let scheduleArray = entity.schedule as? [WeekDay]
        else { return nil }
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: scheduleArray)
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        onDataChanged?()
    }
}
