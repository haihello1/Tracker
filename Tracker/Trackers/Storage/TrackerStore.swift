import CoreData

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>

    var onDataChanged: (() -> Void)?

    init(context: NSManagedObjectContext) {
        self.context = context

        let request = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

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

    func addTracker(_ tracker: Tracker, to category: TrackerCategoryCoreData) throws {
        let entity = TrackerCoreData(context: context)
        entity.id = tracker.id
        entity.name = tracker.name
        entity.color = tracker.color.rawValue
        entity.emoji = tracker.emoji
        entity.schedule = tracker.schedule as NSArray
        entity.category = category
        try context.save()
    }

    var trackers: [Tracker] {
        (fetchedResultsController.fetchedObjects ?? [])
            .compactMap { makeTracker(from: $0) }
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

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        onDataChanged?()
    }
}
