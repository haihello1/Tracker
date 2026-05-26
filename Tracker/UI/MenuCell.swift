import UIKit


enum CellContent {
    case chevron
    case toggle(Bool, (Bool) -> Void)
    case checkmark(Bool)
    case none
}

final class MenuCell: UITableViewCell {

    static let reuseID = "MenuCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .appGray
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        backgroundColor = .appBackground
        separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        titleLabel.font = .ypRegular17
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setupLayout() {
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with model: CellModel) {
        titleLabel.text = model.title

        let hasSubtitle = !(model.subtitle?.isEmpty ?? true)
        subtitleLabel.text = model.subtitle
        subtitleLabel.isHidden = !hasSubtitle
        
        accessoryType = .none
        accessoryView = nil
        selectionStyle = .default

        switch model.type {
        case .chevron:
            accessoryType = .disclosureIndicator

        case .toggle(let isOn, let onChange):
            let toggle = UISwitch()
            toggle.isOn = isOn
            toggle.addAction(UIAction { _ in onChange(toggle.isOn) }, for: .valueChanged)
            accessoryView = toggle
            selectionStyle = .none
            toggle.onTintColor = UIColor(hex: "#3772E7")

        case .checkmark(let isSelected):
            accessoryType = isSelected ? .checkmark : .none

        case .none:
            break
        }
    }

}
