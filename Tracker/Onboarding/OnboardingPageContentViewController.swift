import UIKit

final class OnboardingPageContentViewController: UIViewController {

    private let backgroundImageName: String
    private let labelText: String
    var onSkip: (() -> Void)?

    // MARK: - UI

    private lazy var backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private lazy var descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 32, weight: .bold)
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var actionButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Вот это технологии!"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .black
        config.background.cornerRadius = 16
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return btn
    }()

    // MARK: - Init

    init(backgroundImageName: String, labelText: String) {
        self.backgroundImageName = backgroundImageName
        self.labelText = labelText
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundImageView.image = UIImage(named: backgroundImageName)
        descriptionLabel.text = labelText

        view.addSubview(backgroundImageView)
        view.addSubview(descriptionLabel)
        view.addSubview(actionButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background fills entire screen
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Button: 20pt horizontal insets, 50pt from safe area bottom
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            actionButton.heightAnchor.constraint(equalToConstant: 60),

            // Label: 160pt above button, 16pt horizontal insets
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -160),
        ])
    }

    // MARK: - Actions

    @objc private func didTapButton() {
        onSkip?()
    }
}
