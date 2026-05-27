import UIKit

final class ScheduleViewController: UIViewController {
    var selectedDays: [WeekDay] = []
    
    var onScheduleConfirmed: (([WeekDay]) -> Void)?
    
    var days: [WeekDay: Bool] = Dictionary(
        uniqueKeysWithValues: WeekDay.allCases.map { ($0, false) }
    ) {
        didSet { updateConfirmButton() }
    }
    
    private let menuScrollContainer = UIScrollView()
    private let weekDaysTable = UITableView(frame: .zero, style: .plain)
    private lazy var confirmButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Готово"
        config.background.cornerRadius = AppLayout.cornerRadius
        config.baseBackgroundColor = .appBlack
        config.baseForegroundColor = .appWhite
        let button = UIButton(configuration: config)
        button.isEnabled = false
        button.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        days = Dictionary(
            uniqueKeysWithValues: WeekDay.allCases.map { ($0, selectedDays.contains($0)) }
        )
        configureTable()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.addSubviews(menuScrollContainer, confirmButton)
        weekDaysTable.translatesAutoresizingMaskIntoConstraints = false
        menuScrollContainer.addSubview(weekDaysTable)
        
        view.backgroundColor = .appWhite
        navigationItem.hidesBackButton = true
        navigationItem.title = "Расписание"
        menuScrollContainer.showsVerticalScrollIndicator = false
    }
    
    private func setupConstraints() {
        let totalTableHeight = 75.0 * CGFloat(WeekDay.allCases.count)
        
        NSLayoutConstraint.activate([
            menuScrollContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            menuScrollContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            menuScrollContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            menuScrollContainer.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -16),
            
            weekDaysTable.topAnchor.constraint(equalTo: menuScrollContainer.topAnchor),
            weekDaysTable.leadingAnchor.constraint(equalTo: menuScrollContainer.leadingAnchor),
            weekDaysTable.trailingAnchor.constraint(equalTo: menuScrollContainer.trailingAnchor),
            weekDaysTable.bottomAnchor.constraint(equalTo: menuScrollContainer.bottomAnchor),
            weekDaysTable.widthAnchor.constraint(equalTo: menuScrollContainer.widthAnchor),
            weekDaysTable.heightAnchor.constraint(equalToConstant: totalTableHeight),
            
            confirmButton.heightAnchor.constraint(equalToConstant: 60),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func configureTable() {
        weekDaysTable.delegate = self
        weekDaysTable.dataSource = self
        weekDaysTable.register(MenuCell.self, forCellReuseIdentifier: MenuCell.reuseID)
        weekDaysTable.layer.cornerRadius = AppLayout.cornerRadius
        weekDaysTable.layer.masksToBounds = true
        weekDaysTable.separatorStyle = .singleLine
        weekDaysTable.separatorInset = .zero
        weekDaysTable.layoutMargins = .zero
        weekDaysTable.isScrollEnabled = false
    }
    
    @objc private func confirmTapped() {
        let selectedDays = WeekDay.allCases.filter { days[$0] == true }
        onScheduleConfirmed?(selectedDays)
        navigationController?.popViewController(animated: true)
    }
    
    private func updateConfirmButton() {
        confirmButton.isEnabled = days.values.contains(true)
    }
    
    private func configureCellSeparator(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

// MARK: - UITableViewDataSource extension
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.reuseID, for: indexPath) as? MenuCell else {
            return UITableViewCell()
        }
        configureCellSeparator(tableView: tableView, cell: cell, indexPath: indexPath)
        
        let weekDay = WeekDay.allCases[indexPath.row]
        let isSelected = days[weekDay] ?? false
        
        let cellType = CellContent.toggle(isSelected) { [weak self] newValue in
            self?.days[weekDay] = newValue
        }
        let model = CellModel(title: weekDay.rawValue, subtitle: nil, type: cellType)
        cell.configure(with: model)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { AppLayout.menuCellHeight }
}

extension ScheduleViewController: UITableViewDelegate {}
