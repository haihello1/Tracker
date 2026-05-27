import UIKit

final class OnboardingViewController: UIPageViewController {

    var onFinish: (() -> Void)?

    // MARK: - Pages config

    private struct PageConfig {
        let backgroundImageName: String
        let labelText: String
    }

    private let pages: [PageConfig] = [
        PageConfig(
            backgroundImageName: "onboardingBackgroundBlue",
            labelText: "Отслеживайте только\nто, что хотите"
        ),
        PageConfig(
            backgroundImageName: "onboardingBackgroundRed",
            labelText: "Даже если это\nне литры воды и йога"
        )
    ]

    private var pageViewControllers: [OnboardingPageContentViewController] = []

    // MARK: - UI

    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = pages.count
        pc.currentPage = 0
        pc.currentPageIndicatorTintColor = .black
        pc.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.3)
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.isUserInteractionEnabled = false
        return pc
    }()

    // MARK: - Init

    init() {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        buildPageViewControllers()
        setupPageControl()

        if let first = pageViewControllers.first {
            setViewControllers([first], direction: .forward, animated: false)
        }
    }

    // MARK: - Setup

    private func buildPageViewControllers() {
        pageViewControllers = pages.map { config in
            let vc = OnboardingPageContentViewController(
                backgroundImageName: config.backgroundImageName,
                labelText: config.labelText
            )
            vc.onSkip = { [weak self] in
                self?.finishOnboarding()
            }
            return vc
        }
    }

    private func setupPageControl() {
        view.addSubview(pageControl)

        // pageControl bottom = button top - 24
        // button bottom = safeArea bottom - 50, button height = 60
        // so button top = safeArea bottom - 50 - 60 = safeArea bottom - 110
        // pageControl bottom = safeArea bottom - 110 - 24 = safeArea bottom - 134
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -134
            )
        ])
    }

    // MARK: - Private

    private func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: AppConstants.onboardingShownKey)
        onFinish?()
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard
            let current = viewController as? OnboardingPageContentViewController,
            let index = pageViewControllers.firstIndex(of: current),
            index > 0
        else { return nil }
        return pageViewControllers[index - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard
            let current = viewController as? OnboardingPageContentViewController,
            let index = pageViewControllers.firstIndex(of: current),
            index < pageViewControllers.count - 1
        else { return nil }
        return pageViewControllers[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard
            completed,
            let current = pageViewController.viewControllers?.first as? OnboardingPageContentViewController,
            let index = pageViewControllers.firstIndex(of: current)
        else { return }
        pageControl.currentPage = index
    }
}
