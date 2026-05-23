import UIKit

protocol TrackersCoordinatorProtocol: AnyObject {
    func openCreateTrackerFlow()
}


final class TrackersCoordinator: Coordinator, TrackersCoordinatorProtocol {
    
    var navigationController: UINavigationController
    var child: Coordinator?
    private weak var viewModel: TrackersViewModel?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
    }
    
    func start() {
        let horizontalSpacing = AppLayout.horizontalSpacing
        let parameters = GeometricParams(cellCount: 2, leftInset: horizontalSpacing, rightInset: horizontalSpacing, cellSpacing: 9)
        let vm = TrackersViewModel(coordinator: self)
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
        viewModel?.addTracker(tracker, to: "Важное")
        child = nil
    }
}
