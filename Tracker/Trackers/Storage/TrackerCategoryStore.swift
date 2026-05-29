import CoreData

final class TrackerCategoryStore: NSObject {

    enum StoreError: LocalizedError {
        case categoryAlreadyExists

        var errorDescription: String? {
            switch self {
            case .categoryAlreadyExists:
                return "Категория уже существует"
            }
        }
    }

    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>
    private var observers: [() -> Void] = []

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

    func addObserver(_ observer: @escaping () -> Void) {
        observers.append(observer)
    }

    private func notifyObservers() {
        observers.forEach { $0() }
    }

    func addCategory(title: String) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title =[c] %@", trimmedTitle)

        let existingCategory = try context.fetch(request).first
        guard existingCategory == nil else {
            throw StoreError.categoryAlreadyExists
        }

        let entity = TrackerCategoryCoreData(context: context)
        entity.title = trimmedTitle
        try context.save()
    }

    func findOrCreate(title: String) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        if let existing = try context.fetch(request).first {
            return existing
        }
        let entity = TrackerCategoryCoreData(context: context)
        entity.title = title
        try context.save()
        return entity
    }

    func deleteCategory(title: String) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        if let existing = try context.fetch(request).first {
            context.delete(existing)
            try context.save()
        }
    }

    func updateCategory(oldTitle: String, newTitle: String) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", oldTitle)
        if let existing = try context.fetch(request).first {
            existing.title = newTitle
            try context.save()
        }
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
    
    func deleteTracker(id: UUID) throws {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let results = try context.fetch(request)
        results.forEach { context.delete($0) }
        try context.save()
        notifyObservers()
    }
    
    func updateTracker(_ tracker: Tracker, categoryTitle: String) throws {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)

        guard let existing = try context.fetch(request).first else { return }

        existing.name = tracker.name
        existing.color = tracker.color.rawValue
        existing.emoji = tracker.emoji
        existing.schedule = tracker.schedule as NSArray

        let categoryRequest = TrackerCategoryCoreData.fetchRequest()
        categoryRequest.predicate = NSPredicate(format: "title == %@", categoryTitle)
        if let category = try context.fetch(categoryRequest).first {
            existing.category = category
        }

        try context.save()
        notifyObservers()
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        notifyObservers()
    }
}
