import CoreData

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>

    var onDataChanged: (() -> Void)?

    init(context: NSManagedObjectContext) {
        self.context = context

        let request = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

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

    func addRecord(_ record: TrackerRecord) throws {
        let entity = TrackerRecordCoreData(context: context)
        entity.id = record.id
        entity.date = record.date
        try context.save()
    }

    func deleteRecord(_ record: TrackerRecord) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "id == %@ AND date == %@",
            record.id as CVarArg,
            record.date as CVarArg
        )
        let results = try context.fetch(request)
        results.forEach { context.delete($0) }
        try context.save()
    }

    var records: Set<TrackerRecord> {
        let all = (fetchedResultsController.fetchedObjects ?? [])
            .compactMap { makeRecord(from: $0) }
        return Set(all)
    }

    private func makeRecord(from entity: TrackerRecordCoreData) -> TrackerRecord? {
        guard let id = entity.id, let date = entity.date else { return nil }
        return TrackerRecord(id: id, date: date)
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        onDataChanged?()
    }
}
