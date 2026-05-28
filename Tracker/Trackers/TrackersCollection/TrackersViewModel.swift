// TrackersViewModel.swift

import Foundation

final class TrackersViewModel {

    enum State {
        case content
        case empty
        case noResultsFound
    }

    var onStateChanged: ((State) -> Void)?
    var onDataUpdated: (() -> Void)?

    private weak var coordinator: TrackersCoordinatorProtocol?

    private var categories: [TrackerCategory] = []

    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore

    private var completedTrackers: Set<TrackerRecord> = []
    private var currentDate: Date = Date()
    private var searchQuery: String = ""

    // MARK: Защита от повторных быстрых нажатий
    private var processingRecords: Set<TrackerRecord> = []

    private var visibleCategories: [TrackerCategory] = [] {
        didSet { updateState() }
    }

    private var state: State = .empty {
        didSet {
            onStateChanged?(state)
        }
    }

    init(
        coordinator: TrackersCoordinatorProtocol,
        categoryStore: TrackerCategoryStore,
        recordStore: TrackerRecordStore
    ) {
        self.coordinator = coordinator
        self.categoryStore = categoryStore
        self.recordStore = recordStore

        self.categories = categoryStore.categories
        self.completedTrackers = recordStore.records

        categoryStore.onDataChanged = { [weak self] in
            self?.categories = categoryStore.categories
            self?.applyFilters()
        }

        recordStore.onDataChanged = { [weak self] in
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
        coordinator?.openCreateTrackerFlow()
    }

    func didSelectDate(_ date: Date) {
        currentDate = date
        applyFilters()
    }

    func didChangeSearchQuery(_ query: String) {
        searchQuery = query
        applyFilters()
    }

    func didToggleCompletion(at indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackerCollection[indexPath.item]

        guard !currentDate.isFutureDay else { return }

        let record = TrackerRecord(id: tracker.id, date: currentDate)

        // MARK: Блокируем повторный тап
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

    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        if let index = categories.firstIndex(where: { $0.title == categoryTitle }) {
            let old = categories[index]

            categories[index] = TrackerCategory(
                title: old.title,
                trackerCollection: old.trackerCollection + [tracker]
            )
        } else {
            categories.append(
                TrackerCategory(
                    title: categoryTitle,
                    trackerCollection: [tracker]
                )
            )
        }

        applyFilters()
    }

    private func applyFilters() {
        let weekday = WeekDay.from(date: currentDate)

        visibleCategories = categories.compactMap { category in
            let filtered = category.trackerCollection.filter { tracker in
                let matchesSchedule = tracker.schedule.contains(weekday)

                let matchesQuery = searchQuery.isEmpty
                    || tracker.name.localizedCaseInsensitiveContains(searchQuery)

                return matchesSchedule && matchesQuery
            }

            return filtered.isEmpty
                ? nil
                : TrackerCategory(
                    title: category.title,
                    trackerCollection: filtered
                )
        }

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
