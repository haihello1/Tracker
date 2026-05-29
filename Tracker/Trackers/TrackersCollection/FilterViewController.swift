import UIKit

enum TrackerFilter: Int, CaseIterable {
    case all
    case today
    case completed
    case uncompleted

    var title: String {
        switch self {
        case .all: "Все трекеры"
        case .today: "Трекеры на сегодня"
        case .completed: "Завершённые"
        case .uncompleted: "Незавершённые"
        }
    }
}

protocol FilterViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

final class FilterViewController: UIViewController {

    weak var delegate: FilterViewControllerDelegate?
    private var selectedFilter: TrackerFilter

    private let tableView = UITableView(frame: .zero, style: .plain)

    init(selectedFilter: TrackerFilter) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }

    private func setupUI() {
        view.backgroundColor = .appWhite
        navigationItem.title = "Фильтры"

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.reuseID)
        tableView.layer.cornerRadius = AppLayout.cornerRadius
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .appBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
    }

    private func setupConstraints() {
        let tableHeight = AppLayout.menuCellHeight * CGFloat(TrackerFilter.allCases.count)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: tableHeight)
        ])
    }
}

// MARK: - UITableViewDataSource

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TrackerFilter.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MenuCell.reuseID,
            for: indexPath
        ) as? MenuCell else {
            return UITableViewCell()
        }

        let filter = TrackerFilter.allCases[indexPath.row]
        let isSelected = filter == selectedFilter && filter != .all && filter != .today
        let model = CellModel(title: filter.title, subtitle: nil, type: .checkmark(isSelected))
        cell.configure(with: model)

        let isLast = indexPath.row == TrackerFilter.allCases.count - 1
        cell.separatorInset = isLast
            ? UIEdgeInsets(top: 0, left: 1000, bottom: 0, right: 0)
            : UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        AppLayout.menuCellHeight
    }
}

// MARK: - UITableViewDelegate

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let filter = TrackerFilter.allCases[indexPath.row]
        selectedFilter = filter
        tableView.reloadData()
        delegate?.didSelectFilter(filter)
        dismiss(animated: true)
    }
}
