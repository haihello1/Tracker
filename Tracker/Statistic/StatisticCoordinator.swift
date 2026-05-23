import UIKit

final class StatisticCoordinator: Coordinator {
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = StatisticViewController()
        
        navigationController.setViewControllers([vc], animated: false)
    }
}
