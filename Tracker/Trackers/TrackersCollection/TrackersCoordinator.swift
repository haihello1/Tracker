import UIKit

protocol TrackersCoordinatorProtocol: AnyObject {
    func openCreateTrackerFlow()
    func openEditTrackerFlow(tracker: Tracker, categoryTitle: String, completedDays: Int)
}

final class TrackersCoordinator: Coordinator, TrackersCoordinatorProtocol {

    var navigationController: UINavigationController
    var child: Coordinator?
    // strong — чтобы viewModel не освобождалась до вызова onTrackerEdited
    private var viewModel: TrackersViewModel?
    private let coreDataStack: CoreDataStack
    private let sharedRecordStore: TrackerRecordStore

    private lazy var trackerStore = TrackerStore(context: coreDataStack.context)
    private lazy var categoryStore = TrackerCategoryStore(context: coreDataStack.context)

    init(
        navigationController: UINavigationController,
        coreDataStack: CoreDataStack,
        sharedRecordStore: TrackerRecordStore
    ) {
        self.navigationController = navigationController
        self.coreDataStack = coreDataStack
        self.sharedRecordStore = sharedRecordStore
    }

    func start() {
        let horizontalSpacing = AppLayout.horizontalSpacing
        let parameters = GeometricParams(
            cellCount: 2,
            leftInset: horizontalSpacing,
            rightInset: horizontalSpacing,
            cellSpacing: 9
        )
        let vm = TrackersViewModel(
            categoryStore: categoryStore,
            recordStore: sharedRecordStore
        )
        vm.onAddTrackerTapped = { [weak self] in
            self?.openCreateTrackerFlow()
        }
        self.viewModel = vm
        let vc = TrackersViewController(viewModel: vm, using: parameters)
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }

    func openCreateTrackerFlow() {
        let newTrackerNC = UINavigationController()
        let coordinator = NewTrackerCoordinator(
            navigationController: newTrackerNC,
            categoryStore: categoryStore
        )
        coordinator.onTrackerCreated = { [weak self] tracker, categoryTitle in
            self?.handleNewTracker(tracker, categoryTitle: categoryTitle)
        }
        coordinator.onDismiss = { [weak self] in
            self?.navigationController.dismiss(animated: true)
            self?.child = nil
        }
        child = coordinator
        coordinator.start()
        newTrackerNC.setNavigationBarHidden(false, animated: false)
        navigationController.present(newTrackerNC, animated: true)
    }

    func openEditTrackerFlow(tracker: Tracker, categoryTitle: String, completedDays: Int) {
        let newTrackerNC = UINavigationController()
        let mode = NewTrackerMode.edit(
            tracker: tracker,
            categoryTitle: categoryTitle,
            completedDays: completedDays
        )
        let coordinator = NewTrackerCoordinator(
            navigationController: newTrackerNC,
            categoryStore: categoryStore,
            mode: mode
        )
        coordinator.onTrackerEdited = { [weak self] updatedTracker, newCategoryTitle in
            self?.viewModel?.editTracker(updatedTracker, categoryTitle: newCategoryTitle)
        }
        coordinator.onDismiss = { [weak self] in
            self?.navigationController.dismiss(animated: true)
            self?.child = nil
        }
        child = coordinator
        coordinator.start()
        newTrackerNC.setNavigationBarHidden(false, animated: false)
        navigationController.present(newTrackerNC, animated: true)
    }

    private func handleNewTracker(_ tracker: Tracker, categoryTitle: String) {
        do {
            let category = try categoryStore.findOrCreate(title: categoryTitle)
            try trackerStore.addTracker(tracker, to: category)
        } catch {
            assertionFailure("Failed to save tracker: \(error)")
        }
        child = nil
    }
}
