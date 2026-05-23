import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    func start()
}


final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    private var window: UIWindow?

    var childCoordinators: [Coordinator] = []

    init(window: UIWindow?) {
        self.window = window
        self.navigationController = UINavigationController()
    }

    func start() {
        let tabBarController = UITabBarController()
        configureTabBarAppearance(tabBarController)

        let trackersNC = UINavigationController()
        let trackersCoordinator = TrackersCoordinator(navigationController: trackersNC)
        trackersNC.tabBarItem = UITabBarItem(
            title: "Tracker",
            image: UIImage(resource: .trackerSectionLogo),
            selectedImage: UIImage(resource: .trackerSectionLogo)
        )

        let statisticNC = UINavigationController()
        let statisticCoordinator = StatisticCoordinator(navigationController: statisticNC)
        statisticNC.tabBarItem = UITabBarItem(
            title: "Statistic",
            image: UIImage(resource: .statisticSectionLogo),
            selectedImage: UIImage(resource: .statisticSectionLogo)
        )

        trackersCoordinator.start()
        statisticCoordinator.start()

        childCoordinators = [trackersCoordinator, statisticCoordinator]

        tabBarController.viewControllers = [trackersNC, statisticNC]

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

    private func configureTabBarAppearance(_ tabBar: UITabBarController) {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .appWhite

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.selected.iconColor = .appBlue
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.appBlue
        ]
        itemAppearance.normal.iconColor = .appGray
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.appGray
        ]

        appearance.stackedLayoutAppearance = itemAppearance
        tabBar.tabBar.standardAppearance = appearance
        tabBar.tabBar.scrollEdgeAppearance = appearance
    }
}
