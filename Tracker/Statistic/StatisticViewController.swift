import UIKit

final class StatisticViewController: UIViewController {

    private let recordStore: TrackerRecordStore

    init(recordStore: TrackerRecordStore) {
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    private lazy var sectionNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Статистика"
        lbl.font = .ypBold34
        return lbl
    }()

    private lazy var emptyView: EmptyView = {
        let ev = EmptyView()
        ev.configure(
            text: "Пока нечего анализировать",
            image: UIImage(resource: .emptyStatisticView)
        )
        return ev
    }()

    private lazy var completedTrackersView = StatisticCardView(
        value: "0",
        title: "Трекеров завершено"
    )

    private lazy var statisticsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [completedTrackersView])
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStats()
    }

    private func updateStats() {
        let count = recordStore.records.count
        if count == 0 {
            statisticsStackView.isHidden = true
            emptyView.isHidden = false
        } else {
            statisticsStackView.isHidden = false
            emptyView.isHidden = true
            completedTrackersView.update(value: "\(count)")
        }
    }

    private func setUI() {
        view.backgroundColor = .appWhite
        view.addSubviews(sectionNameLabel, emptyView, statisticsStackView)
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            sectionNameLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: AppLayout.horizontalSpacing
            ),
            sectionNameLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 44
            ),

            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            statisticsStackView.topAnchor.constraint(
                equalTo: sectionNameLabel.bottomAnchor,
                constant: 24
            ),
            statisticsStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            statisticsStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            )
        ])
    }
}

final class StatisticCardView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    private let shapeLayer = CAShapeLayer()
    
    private lazy var valueLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .ypBold34
        lbl.textColor = .appBlack
        lbl.text = value
        return lbl
    }()
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .ypMedium12
        lbl.textColor = .appBlack
        lbl.text = title
        return lbl
    }()
    
    private let value: String
    private let title: String
    
    init(value: String, title: String) {
        self.value = value
        self.title = title
        
        super.init(frame: .zero)
        
        setupUI()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        
        let inset = shapeLayer.lineWidth / 2
        
        let rect = bounds.insetBy(dx: inset, dy: inset)
        
        let path = UIBezierPath(
            roundedRect: rect,
            cornerRadius: 16
        )
        
        shapeLayer.path = path.cgPath
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        backgroundColor = .clear
        layer.cornerRadius = 16
        
        setupGradientBorder()
        
        addSubviews(valueLabel, titleLabel)
    }
    
    private func setupGradientBorder() {
        gradientLayer.colors = [
            UIColor(hex: "#FD4C49").cgColor,
            UIColor(hex: "#46E69D").cgColor,
            UIColor(hex: "#007BFA").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        shapeLayer.lineWidth = 1 / UIScreen.main.scale
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor // непрозрачный = маска пропускает градиент

        gradientLayer.mask = shapeLayer

        layer.insertSublayer(gradientLayer, at: 0) // под лейблами
    }

    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 90),
            
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 6),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
    }
    
    func update(value: String) {
        valueLabel.text = value
    }
}
