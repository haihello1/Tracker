import UIKit

final class NewTrackerViewController: UIViewController {


    var onTrackerCreated: ((Tracker) -> Void)?
    var coordinator: NewTrackerCoordinatorProtocol?
    private let viewModel: NewTrackerViewModel


    private let trackerNameTextField = UITextField()
    private let textFieldWarning = UILabel()
    private let trackerSettingsTable = UITableView(frame: .zero, style: .plain)
    private let menuScrollContainer = UIScrollView()

    private lazy var cancelButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        config.title = "Отменить"
        config.baseForegroundColor = .appRed
        config.baseBackgroundColor = .clear
        config.background.strokeColor = .appRed
        config.background.strokeWidth = 1
        config.background.cornerRadius = AppLayout.cornerRadius

        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var createButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Создать"
        config.background.cornerRadius = AppLayout.cornerRadius
        config.baseBackgroundColor = .appBlack
        config.baseForegroundColor = .appWhite

        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }()


    private let tableTopSpacingDefault = 24.0
    private let tableTopSpacingWithWarning = 54.0
    private var tableTopConstraint: NSLayoutConstraint!


    init(viewModel: NewTrackerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupUI()
        setupNavBar()
        setupConstraints()
        setupWarning()
        bindViewModel()
    }


    private func bindViewModel() {
        viewModel.onScheduleUpdated = { [weak self] indexPath in
            self?.trackerSettingsTable.reloadRows(at: [indexPath], with: .none)
        }

        viewModel.onFormValidChanged = { [weak self] isValid in
            self?.updateCreateButton(isEnabled: isValid)
        }
    }


    private func updateCreateButton(isEnabled: Bool) {
        createButton.isEnabled = isEnabled
        createButton.configuration?.baseBackgroundColor = isEnabled
            ? .appBlack
            : .appBlack.withAlphaComponent(0.3)
    }

    private func showWarning(_ show: Bool) {
        textFieldWarning.isHidden = !show
        tableTopConstraint.constant = show
            ? tableTopSpacingWithWarning
            : tableTopSpacingDefault

        UIView.animate(withDuration: 0.05) {
            self.view.layoutIfNeeded()
        }
    }


    private func setupWarning() {
        textFieldWarning.text = "Ограничение 38 символов"
        textFieldWarning.font = .systemFont(ofSize: 17, weight: .regular)
        textFieldWarning.textColor = .appRed
        textFieldWarning.isHidden = true
    }

    private func setupTableView() {
        trackerSettingsTable.layer.cornerRadius = AppLayout.cornerRadius
        trackerSettingsTable.layer.masksToBounds = true
        trackerSettingsTable.clipsToBounds = true
        trackerSettingsTable.dataSource = self
        trackerSettingsTable.delegate = self
        trackerSettingsTable.register(MenuCell.self, forCellReuseIdentifier: MenuCell.reuseID)
        trackerSettingsTable.separatorStyle = .singleLine
        trackerSettingsTable.separatorInset = .zero
        trackerSettingsTable.layoutMargins = .zero
        trackerSettingsTable.isScrollEnabled = false
    }

    private func setupNavBar() {
        navigationItem.title = "Новая привычка"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.appBlack
        ]
    }

    private func setupUI() {
        view.backgroundColor = .appWhite
        view.addSubviews(menuScrollContainer, trackerNameTextField, textFieldWarning, buttonsStack)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        trackerSettingsTable.translatesAutoresizingMaskIntoConstraints = false
        menuScrollContainer.addSubview(trackerSettingsTable)
        menuScrollContainer.showsVerticalScrollIndicator = false
        
        trackerNameTextField.delegate = self
        trackerNameTextField.placeholder = "Введите название трекера"
        trackerNameTextField.layer.cornerRadius = AppLayout.cornerRadius
        trackerNameTextField.layer.backgroundColor = UIColor.appBackground.cgColor
        trackerNameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        trackerNameTextField.leftViewMode = .always
        trackerNameTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 75))
        trackerNameTextField.rightViewMode = .always
        trackerNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    private func setupConstraints() {
        let horizontalSpacing = AppLayout.horizontalSpacing
        let interItemSpacing = 24.0
        let warningHeight = 22.0
        let warningSpacing = 8.0
        let cellsAmount = viewModel.numberOfSettingsSections
        let tableHeight = AppLayout.menuCellHeight * CGFloat(cellsAmount)

        tableTopConstraint = menuScrollContainer.topAnchor.constraint(
            equalTo: trackerNameTextField.bottomAnchor,
            constant: interItemSpacing
        )

        NSLayoutConstraint.activate([
            trackerNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalSpacing),
            trackerNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalSpacing),
            trackerNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: interItemSpacing),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),

            textFieldWarning.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: warningSpacing),
            textFieldWarning.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textFieldWarning.heightAnchor.constraint(equalToConstant: warningHeight),

            tableTopConstraint,

            menuScrollContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalSpacing),
            menuScrollContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalSpacing),
            menuScrollContainer.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor),

            trackerSettingsTable.leadingAnchor.constraint(equalTo: menuScrollContainer.leadingAnchor),
            trackerSettingsTable.trailingAnchor.constraint(equalTo: menuScrollContainer.trailingAnchor),
            trackerSettingsTable.topAnchor.constraint(equalTo: menuScrollContainer.topAnchor),
            trackerSettingsTable.widthAnchor.constraint(equalTo: menuScrollContainer.widthAnchor),
            trackerSettingsTable.heightAnchor.constraint(equalToConstant: tableHeight),
            trackerSettingsTable.bottomAnchor.constraint(equalTo: menuScrollContainer.bottomAnchor),

            buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonsStack.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func createButtonTapped() {
        let tracker = viewModel.buildTracker()
        onTrackerCreated?(tracker)
        coordinator?.dismiss()
    }

    @objc private func cancelButtonTapped() {
        coordinator?.dismiss()
    }

    @objc private func textFieldDidChange() {
        let text = trackerNameTextField.text ?? ""
        showWarning(text.count > 37)
        viewModel.updateTrackerName(text)
    }
}


extension NewTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row == 1 {
            coordinator?.showScheduleSection(selectedDays: viewModel.selectedSchedule) { [weak self] days in
                self?.viewModel.updateSchedule(with: days)
            }
        }
    }
}


extension NewTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfSettingsSections
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.reuseID, for: indexPath) as? MenuCell else {
            return UITableViewCell()
        }

        configureCellSeparator(tableView: tableView, cell: cell, indexPath: indexPath)
        let cellModel = viewModel.cellModel(forRowAt: indexPath)
        cell.configure(with: cellModel)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        AppLayout.menuCellHeight
    }

    private func configureCellSeparator(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        let isLast = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        cell.separatorInset = isLast
            ? UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
            : UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}


extension NewTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
