import UIKit

protocol TrackersCoordinatorProtocol: AnyObject {
    func openCreateTrackerFlow()
}


final class TrackersCoordinator: Coordinator, TrackersCoordinatorProtocol {
    
    var navigationController: UINavigationController
    var child: Coordinator?
    private weak var viewModel: TrackersViewModel?
    private let coreDataStack: CoreDataStack
    
    private lazy var trackerStore = TrackerStore(context: coreDataStack.context)
    private lazy var categoryStore = TrackerCategoryStore(context: coreDataStack.context)
    private lazy var recordStore = TrackerRecordStore(context: coreDataStack.context)

    init(navigationController: UINavigationController, coreDataStack: CoreDataStack) {
        self.navigationController = navigationController
        self.coreDataStack = coreDataStack
    }
    
    func start() {
        let horizontalSpacing = AppLayout.horizontalSpacing
        let parameters = GeometricParams(cellCount: 2, leftInset: horizontalSpacing, rightInset: horizontalSpacing, cellSpacing: 9)
        let vm = TrackersViewModel(
            coordinator: self,
            categoryStore: categoryStore,
            recordStore: recordStore
        )
        self.viewModel = vm
        let vc = TrackersViewController(viewModel: vm, using: parameters)
        navigationController.setViewControllers([vc], animated: false)
    }
        
    func openCreateTrackerFlow() {
        let newTrackerNC = UINavigationController()
        let trackerCreationCoordinator = NewTrackerCoordinator(navigationController: newTrackerNC)
        
        trackerCreationCoordinator.onTrackerCreated = { [weak self] tracker in
            self?.handleNewTracker(tracker)
        }
        
        trackerCreationCoordinator.onDismiss = { [weak self] in
            self?.navigationController.dismiss(animated: true)
            self?.child = nil
        }
        
        child = trackerCreationCoordinator
        trackerCreationCoordinator.start()
        newTrackerNC.setNavigationBarHidden(false, animated: false)
        navigationController.present(newTrackerNC, animated: true)
    }
    
    private func handleNewTracker(_ tracker: Tracker) {
        do {
            let category = try categoryStore.findOrCreate(title: "Важное")
            try trackerStore.addTracker(tracker, to: category)
        } catch {
            assertionFailure("Failed to save tracker: \(error)")
        }
        child = nil
    }
}
