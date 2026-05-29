import Foundation

final class TrackersViewModel {

    enum State {
        case content
        case empty
        case noResultsFound
    }

    var onStateChanged: ((State) -> Void)?
    var onDataUpdated: (() -> Void)?
    var onAddTrackerTapped: (() -> Void)?
    var onDateChanged: ((Date) -> Void)?

    private var categories: [TrackerCategory] = []

    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore

    private var completedTrackers: Set<TrackerRecord> = []
    private(set) var currentDate: Date = Date()
    private var searchQuery: String = ""
    private var processingRecords: Set<TrackerRecord> = []
    private(set) var currentFilter: TrackerFilter = .all

    private var visibleCategories: [TrackerCategory] = [] {
        didSet { updateState() }
    }

    private var state: State = .empty {
        didSet { onStateChanged?(state) }
    }

    init(
        categoryStore: TrackerCategoryStore,
        recordStore: TrackerRecordStore
    ) {
        self.categoryStore = categoryStore
        self.recordStore = recordStore

        self.categories = categoryStore.categories
        self.completedTrackers = recordStore.records

        categoryStore.addObserver { [weak self] in
            self?.categories = categoryStore.categories
            self?.applyFilters()
        }

        recordStore.addObserver { [weak self] in
            self?.completedTrackers = recordStore.records
            self?.processingRecords.removeAll()
            self?.applyFilters()
        }
    }

    func viewDidLoad() {
        applyFilters()
    }

    var numberOfSections: Int {
        visibleCategories.count
    }
    
    var hasTrackersForCurrentDay: Bool {
        let weekday = WeekDay.from(date: currentDate)
        return categories.contains { category in
            category.trackerCollection.contains { tracker in
                tracker.schedule.contains(weekday)
            }
        }
    }
    
    func numberOfItems(in section: Int) -> Int {
        visibleCategories[section].trackerCollection.count
    }

    func categoryTitle(for section: Int) -> String {
        visibleCategories[section].title
    }

    func cellViewModel(at indexPath: IndexPath) -> TrackerCellViewModel {
        let tracker = visibleCategories[indexPath.section].trackerCollection[indexPath.item]

        let isCompleted = completedTrackers.contains {
            $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }

        let completedDays = completedTrackers.filter {
            $0.id == tracker.id
        }.count

        return TrackerCellViewModel(
            emoji: tracker.emoji,
            title: tracker.name,
            color: tracker.color,
            isCompleted: isCompleted,
            completedDays: completedDays
        )
    }

    func didTapAddTrackersButton() {
        onAddTrackerTapped?()
    }

    func didSelectDate(_ date: Date) {
        currentDate = date
        applyFilters()
    }

    func didChangeSearchQuery(_ query: String) {
        searchQuery = query
        applyFilters()
    }

    func didSelectFilter(_ filter: TrackerFilter) {
        currentFilter = filter
        if filter == .today {
            currentDate = Date()
            onDateChanged?(currentDate)
        }
        applyFilters()
    }

    func didToggleCompletion(at indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackerCollection[indexPath.item]

        guard !currentDate.isFutureDay else { return }

        let record = TrackerRecord(id: tracker.id, date: currentDate)

        guard !processingRecords.contains(record) else { return }
        processingRecords.insert(record)

        do {
            if completedTrackers.contains(record) {
                try recordStore.deleteRecord(record)
            } else {
                try recordStore.addRecord(record)
            }
        } catch {
            processingRecords.remove(record)
            assertionFailure("Failed to toggle record: \(error)")
        }
    }
    
    func trackerAndCategory(at indexPath: IndexPath) -> (Tracker, String, Int) {
        let tracker = visibleCategories[indexPath.section].trackerCollection[indexPath.item]
        let categoryTitle = visibleCategories[indexPath.section].title
        let completedDays = completedTrackers.filter { $0.id == tracker.id }.count
        return (tracker, categoryTitle, completedDays)
    }

    func editTracker(_ tracker: Tracker, categoryTitle: String) {
        do {
            try categoryStore.updateTracker(tracker, categoryTitle: categoryTitle)
        } catch {
            assertionFailure("Failed to edit tracker: \(error)")
        }
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackerCollection[indexPath.item]
        do {
            try categoryStore.deleteTracker(id: tracker.id)
        } catch {
            assertionFailure("Failed to delete tracker: \(error)")
        }
    }

    // MARK: - Private

    private func applyFilters() {
        let weekday = WeekDay.from(date: currentDate)

        let filtered = categories.compactMap { category -> TrackerCategory? in
            let trackers = category.trackerCollection.filter { tracker in
                let matchesSchedule = tracker.schedule.contains(weekday)
                let matchesQuery = searchQuery.isEmpty
                    || tracker.name.localizedCaseInsensitiveContains(searchQuery)
                guard matchesSchedule && matchesQuery else { return false }

                switch currentFilter {
                case .all, .today:
                    return true
                case .completed:
                    return completedTrackers.contains {
                        $0.id == tracker.id &&
                        Calendar.current.isDate($0.date, inSameDayAs: currentDate)
                    }
                case .uncompleted:
                    return !completedTrackers.contains {
                        $0.id == tracker.id &&
                        Calendar.current.isDate($0.date, inSameDayAs: currentDate)
                    }
                }
            }
            return trackers.isEmpty
                ? nil
                : TrackerCategory(title: category.title, trackerCollection: trackers)
        }

        visibleCategories = filtered
        onDataUpdated?()
    }

    private func updateState() {
        if categories.isEmpty {
            state = .empty
        } else if visibleCategories.isEmpty {
            state = .noResultsFound
        } else {
            state = .content
        }
    }
}
