import UIKit

protocol NewTrackerCoordinatorProtocol {
    func showCategorySection()
    func showScheduleSection(selectedDays: [WeekDay], onConfirm: @escaping ([WeekDay]) -> Void)
    func dismiss()
}

final class NewTrackerCoordinator: Coordinator, NewTrackerCoordinatorProtocol {
    
    var navigationController: UINavigationController
    var onTrackerCreated: ((Tracker) -> Void)?
    var onDismiss: (() -> Void)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = NewTrackerViewController(viewModel: NewTrackerViewModel())
        vc.coordinator = self
        vc.onTrackerCreated = onTrackerCreated
        navigationController.setViewControllers([vc], animated: true)
    }
    
    // TODO: будет реализовано в следующем спринте
    func showCategorySection() {}

    func showScheduleSection(selectedDays: [WeekDay], onConfirm: @escaping ([WeekDay]) -> Void) {
        let vc = ScheduleViewController()
        vc.onScheduleConfirmed = onConfirm
        vc.selectedDays = selectedDays
        navigationController.pushViewController(vc, animated: true)
    }
    
    func dismiss() {
        onDismiss?()
    }
}
