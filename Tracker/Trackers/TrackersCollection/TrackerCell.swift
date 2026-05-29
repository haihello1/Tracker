import UIKit


private enum Layout {
    static let emojiContainerSize: CGFloat = 28
    static let completeButtonSize: CGFloat = 34
}

final class TrackerCell: UICollectionViewCell {
    
    static let reuseID = "trackerCell"

    private let emojiLabel = UILabel()
    private let trackerNameLabel = UILabel()
    private let dayCounterLabel = UILabel()
    private let completeButton = UIButton()
    
    private let emojiContainerView = UIView()
    private let topContainerView = UIView()
    private let bottomContainerView = UIView()
    
    private var color: UIColor?
    var onCompleteButtonTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onCompleteButtonTapped = nil
    }
    
    private func setupUI() {
        [topContainerView, dayCounterLabel, completeButton, emojiContainerView, emojiLabel, trackerNameLabel, bottomContainerView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        trackerNameLabel.numberOfLines = 2

        // Top container
        emojiContainerView.addSubview(emojiLabel)
        topContainerView.addSubview(emojiContainerView)
        topContainerView.addSubview(trackerNameLabel)
        contentView.addSubview(topContainerView)
        
        // Bottom container
        bottomContainerView.addSubview(dayCounterLabel)
        bottomContainerView.addSubview(completeButton)
        contentView.addSubview(bottomContainerView)
        
        trackerNameLabel.font = .ypMedium12
        trackerNameLabel.textColor = .white
        
        dayCounterLabel.font = .ypMedium12
        dayCounterLabel.textColor = .appBlack
        
        topContainerView.backgroundColor = color
        topContainerView.layer.cornerRadius = AppLayout.cornerRadius
        topContainerView.clipsToBounds = true
        
        completeButton.tintColor = .white
        completeButton.setImage(UIImage(systemName: "plus"), for: .normal)
        completeButton.layer.cornerRadius = Layout.completeButtonSize / 2
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        
        emojiContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        emojiContainerView.layer.cornerRadius = Layout.emojiContainerSize / 2
        emojiContainerView.clipsToBounds = true
        
        topContainerView.layer.borderWidth = 1
        topContainerView.layer.borderColor = UIColor.appGray.cgColor
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Top container
            topContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topContainerView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 2/3),
            
            emojiContainerView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 12),
            emojiContainerView.topAnchor.constraint(equalTo: topContainerView.topAnchor, constant: 12),
            emojiContainerView.heightAnchor.constraint(equalToConstant: Layout.emojiContainerSize),
            emojiContainerView.widthAnchor.constraint(equalToConstant: Layout.emojiContainerSize),
            
            trackerNameLabel.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 12),
            trackerNameLabel.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -12),
            trackerNameLabel.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor, constant: -12),
            
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiContainerView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiContainerView.centerYAnchor),
            
            // Bottom container
            bottomContainerView.topAnchor.constraint(equalTo: topContainerView.bottomAnchor),
            bottomContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomContainerView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1/3),
            bottomContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            dayCounterLabel.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 16),
            dayCounterLabel.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 12),
            
            completeButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -12),
            completeButton.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 8),
            completeButton.heightAnchor.constraint(equalToConstant: Layout.completeButtonSize),
            completeButton.widthAnchor.constraint(equalToConstant: Layout.completeButtonSize)
        ])
    }
        
    func configure(with viewModel: TrackerCellViewModel) {
        self.emojiLabel.text = viewModel.emoji
        self.trackerNameLabel.text = viewModel.title
        self.color = viewModel.color.uiColor
        self.dayCounterLabel.text = makeCorrectDayEnding(viewModel.completedDays)
        
        topContainerView.backgroundColor = viewModel.color.uiColor
        completeButton.backgroundColor = viewModel.color.uiColor
        
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold)
        if viewModel.isCompleted {
            let image = UIImage(systemName: "checkmark", withConfiguration: config)
            completeButton.setImage(image, for: .normal)
            completeButton.backgroundColor = viewModel.color.uiColor.withAlphaComponent(0.3)
        } else {
            completeButton.setImage(UIImage(systemName: "plus"), for: .normal)
            completeButton.backgroundColor = viewModel.color.uiColor
        }
    }
    
    private func makeCorrectDayEnding(_ count: Int) -> String {
        let lastTwoDigits = count % 100
        let lastDigit = count % 10

        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            return String(format: "days_many".localized, count)
        }

        switch lastDigit {
        case 1:
            return String(format: "days_one".localized, count)
        case 2...4:
            return String(format: "days_few".localized, count)
        default:
            return String(format: "days_many".localized, count)
        }
    }
    
    @objc private func completeButtonTapped() {
        onCompleteButtonTapped?()
    }
}


final class HeaderView: UICollectionReusableView {
    static let reuseID = "HeaderView"
    
    let headerLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setupUI() {
        addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            headerLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        headerLabel.font = .ypBold19
    }
    
    func configure(headerTitle text: String) {
        self.headerLabel.text = text
    }
}
