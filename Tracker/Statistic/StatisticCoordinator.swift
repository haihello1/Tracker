import UIKit

final class StatisticCoordinator: Coordinator {
    var navigationController: UINavigationController
    private let recordStore: TrackerRecordStore

    init(navigationController: UINavigationController, recordStore: TrackerRecordStore) {
        self.navigationController = navigationController
        self.recordStore = recordStore
    }

    func start() {
        let vc = StatisticViewController(recordStore: recordStore)
        navigationController.setViewControllers([vc], animated: false)
    }
}
