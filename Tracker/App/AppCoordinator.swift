import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    func start()
}


final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    private var window: UIWindow?
    private let coreDataStack: CoreDataStack

    var childCoordinators: [Coordinator] = []

    init(window: UIWindow?, coreDataStack: CoreDataStack) {
         self.window = window
         self.coreDataStack = coreDataStack
         self.navigationController = UINavigationController()
     }

    func start() {
        let onboardingShown = UserDefaults.standard.bool(forKey: AppConstants.onboardingShownKey)
        if onboardingShown {
            showMainFlow()
        } else {
            showOnboarding()
        }
    }

    // MARK: - Private

    private func showOnboarding() {
        let onboardingVC = OnboardingViewController()
        onboardingVC.onFinish = { [weak self] in
            self?.showMainFlow()
        }
        window?.rootViewController = onboardingVC
        window?.makeKeyAndVisible()
    }

    private func showMainFlow() {
        let tabBarController = UITabBarController()
        configureTabBarAppearance(tabBarController)

        // Сначала создаём recordStore
        let recordStore = TrackerRecordStore(context: coreDataStack.context)

        let trackersNC = UINavigationController()
        let trackersCoordinator = TrackersCoordinator(
            navigationController: trackersNC,
            coreDataStack: coreDataStack,
            sharedRecordStore: recordStore
        )
        trackersNC.tabBarItem = UITabBarItem(
            title: "tab_trackers".localized,
            image: UIImage(resource: .trackerSectionLogo),
            selectedImage: UIImage(resource: .trackerSectionLogo)
        )

        let statisticNC = UINavigationController()
        let statisticCoordinator = StatisticCoordinator(
            navigationController: statisticNC,
            recordStore: recordStore
        )
        statisticNC.tabBarItem = UITabBarItem(
            title: "tab_statistics".localized,
            image: UIImage(resource: .statisticSectionLogo),
            selectedImage: UIImage(resource: .statisticSectionLogo)
        )

        trackersCoordinator.start()
        statisticCoordinator.start()

        childCoordinators = [trackersCoordinator, statisticCoordinator]

        tabBarController.viewControllers = [trackersNC, statisticNC]

        if let current = window?.rootViewController, !(current is UITabBarController) {
            guard let window else { return }
            UIView.transition(
                with: window,
                duration: 0.4,
                options: .transitionCrossDissolve,
                animations: { self.window?.rootViewController = tabBarController },
                completion: nil
            )
        } else {
            window?.rootViewController = tabBarController
            window?.makeKeyAndVisible()
        }
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
