import UIKit

protocol NewTrackerCoordinatorProtocol {
    func showCategorySection(selectedCategory: String?, onConfirm: @escaping (String) -> Void)
    func showScheduleSection(selectedDays: [WeekDay], onConfirm: @escaping ([WeekDay]) -> Void)
    func dismiss()
}

final class NewTrackerCoordinator: Coordinator, NewTrackerCoordinatorProtocol {
    
    var navigationController: UINavigationController
    var onTrackerCreated: ((Tracker, String) -> Void)?
    var onDismiss: (() -> Void)?
    
    private let categoryStore: TrackerCategoryStore
    
    init(navigationController: UINavigationController, categoryStore: TrackerCategoryStore) {
        self.navigationController = navigationController
        self.categoryStore = categoryStore
    }

    func start() {
        let vc = NewTrackerViewController(viewModel: NewTrackerViewModel())
        vc.coordinator = self
        vc.onTrackerCreated = onTrackerCreated
        navigationController.setViewControllers([vc], animated: true)
    }
    
    func showCategorySection(selectedCategory: String?, onConfirm: @escaping (String) -> Void) {
        let viewModel = CategoryViewModel(categoryStore: categoryStore, selectedCategory: selectedCategory)
        viewModel.onCategorySelected = onConfirm
        viewModel.onDismiss = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        let vc = CategoryViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }


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
