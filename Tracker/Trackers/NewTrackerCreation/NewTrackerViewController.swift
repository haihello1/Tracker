import UIKit

final class NewTrackerViewController: UIViewController {

    var onTrackerCreated: ((Tracker) -> Void)?
    var coordinator: NewTrackerCoordinatorProtocol?
    private let viewModel: NewTrackerViewModel

    private let trackerNameTextField = UITextField()
    private let textFieldWarning = UILabel()
    private let trackerSettingsTable = UITableView(frame: .zero, style: .plain)
    private let menuScrollContainer = UIScrollView()
    private let emojiColorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    private var selectedEmojiIndex: IndexPath?
    private var selectedColorIndex: IndexPath?
    
    private var collectionHeightConstraint: NSLayoutConstraint!
    private let maxTrackerNameLenght = 38
    private enum Section: Int, CaseIterable {
        case emoji = 0
        case color = 1

        var title: String {
            switch self {
            case .emoji: return "Emoji"
            case .color: return "Цвет"
            }
        }
    }

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

    private func calculateItemSize(for collectionView: UICollectionView) -> CGFloat {
        let totalSpacing =
            sectionInset * 2 +
            (columns - 1) * itemSpacing

        return (collectionView.bounds.width - totalSpacing) / columns
    }
    
    private let itemSpacing: CGFloat = 5
    private let sectionInset: CGFloat = 18
    private let columns: CGFloat = 6
    private let rowsPerSection: CGFloat = 3

    init(viewModel: NewTrackerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupCollectionView()
        setupUI()
        setupNavBar()
        setupConstraints()
        setupWarning()
        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let itemSize = calculateItemSize(for: emojiColorCollectionView)

        let headerHeight: CGFloat = 50

        let sectionHeight =
            rowsPerSection * itemSize +
            (rowsPerSection - 1) * itemSpacing +
            sectionInset * 2 +
            headerHeight

        collectionHeightConstraint.constant =
            sectionHeight * CGFloat(Section.allCases.count)
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
        tableTopConstraint.constant = show ? tableTopSpacingWithWarning : tableTopSpacingDefault
        UIView.animate(withDuration: 0.05) { self.view.layoutIfNeeded() }
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

    private func setupCollectionView() {
        emojiColorCollectionView.dataSource = self
        emojiColorCollectionView.delegate = self
        emojiColorCollectionView.isScrollEnabled = false
        emojiColorCollectionView.backgroundColor = .clear
        emojiColorCollectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseID)
        emojiColorCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseID)
        emojiColorCollectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseID
        )
    }

    private func setupNavBar() {
        navigationItem.title = "Новая привычка"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.appBlack]
    }

    private func setupUI() {
        view.backgroundColor = .appWhite

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        trackerNameTextField.delegate = self
        trackerNameTextField.placeholder = "Введите название трекера"
        trackerNameTextField.layer.cornerRadius = AppLayout.cornerRadius
        trackerNameTextField.layer.backgroundColor = UIColor.appBackground.cgColor
        trackerNameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        trackerNameTextField.leftViewMode = .always
        trackerNameTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 75))
        trackerNameTextField.rightViewMode = .always
        trackerNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        trackerSettingsTable.translatesAutoresizingMaskIntoConstraints = false
        emojiColorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        menuScrollContainer.showsVerticalScrollIndicator = false
        menuScrollContainer.addSubview(trackerSettingsTable)
        menuScrollContainer.addSubview(emojiColorCollectionView)

        [trackerNameTextField, textFieldWarning, menuScrollContainer, buttonsStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    private func setupConstraints() {
        let horizontalSpacing = AppLayout.horizontalSpacing
        let interItemSpacing = 24.0
        let warningHeight = 22.0
        let warningSpacing = 8.0
        let cellsAmount = viewModel.numberOfSettingsSections
        let tableHeight = AppLayout.menuCellHeight * CGFloat(cellsAmount)
        collectionHeightConstraint = emojiColorCollectionView.heightAnchor.constraint(equalToConstant: 0)
        
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
            menuScrollContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menuScrollContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            menuScrollContainer.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor),

            trackerSettingsTable.topAnchor.constraint(equalTo: menuScrollContainer.topAnchor),
            trackerSettingsTable.leadingAnchor.constraint(equalTo: menuScrollContainer.leadingAnchor, constant: horizontalSpacing),
            trackerSettingsTable.trailingAnchor.constraint(equalTo: menuScrollContainer.trailingAnchor, constant: -horizontalSpacing),
            trackerSettingsTable.widthAnchor.constraint(equalTo: menuScrollContainer.widthAnchor, constant: -horizontalSpacing * 2),
            trackerSettingsTable.heightAnchor.constraint(equalToConstant: tableHeight),

            emojiColorCollectionView.topAnchor.constraint(equalTo: trackerSettingsTable.bottomAnchor, constant: interItemSpacing),
            emojiColorCollectionView.leadingAnchor.constraint(equalTo: menuScrollContainer.leadingAnchor),
            emojiColorCollectionView.trailingAnchor.constraint(equalTo: menuScrollContainer.trailingAnchor),
            emojiColorCollectionView.widthAnchor.constraint(equalTo: menuScrollContainer.widthAnchor),
            collectionHeightConstraint,
            emojiColorCollectionView.bottomAnchor.constraint(equalTo: menuScrollContainer.bottomAnchor),

            buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonsStack.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    @objc private func createButtonTapped() {
        let tracker = viewModel.buildTracker()
        onTrackerCreated?(tracker)
        coordinator?.dismiss()
    }

    @objc private func cancelButtonTapped() { coordinator?.dismiss() }

    @objc private func textFieldDidChange() {
        let text = trackerNameTextField.text ?? ""
        showWarning(text.count >= maxTrackerNameLenght)
        viewModel.updateTrackerName(text)
    }
}

// MARK: - UITableViewDelegate & DataSource

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
        cell.configure(with: viewModel.cellModel(forRowAt: indexPath))
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

// MARK: - UICollectionViewDataSource

extension NewTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .emoji: return viewModel.emojis.count
        case .color: return viewModel.colors.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .emoji:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseID, for: indexPath) as? EmojiCell else {
                return UICollectionViewCell()
            }
            let emoji = viewModel.emojis[indexPath.item]
            cell.configure(emoji: emoji, isSelected: indexPath == selectedEmojiIndex)
            return cell

        case .color:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseID, for: indexPath) as? ColorCell else {
                return UICollectionViewCell()
            }
            let color = viewModel.colors[indexPath.item]
            cell.configure(color: color.uiColor, isSelected: indexPath == selectedColorIndex)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.reuseID,
            for: indexPath
        ) as? SectionHeaderView else {
            return UICollectionReusableView()
        }
        header.configure(title: Section(rawValue: indexPath.section)!.title)
        return header
    }
}

// MARK: - UICollectionViewDelegate

extension NewTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section)! {
        case .emoji:
            let prev = selectedEmojiIndex
            selectedEmojiIndex = indexPath
            var toReload = [indexPath]
            if let prev, prev != indexPath { toReload.append(prev) }
            collectionView.reloadItems(at: toReload)
            viewModel.selectEmoji(viewModel.emojis[indexPath.item])

        case .color:
            let prev = selectedColorIndex
            selectedColorIndex = indexPath
            var toReload = [indexPath]
            if let prev, prev != indexPath { toReload.append(prev) }
            collectionView.reloadItems(at: toReload)
            viewModel.selectColor(viewModel.colors[indexPath.item])
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension NewTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (collectionView.bounds.width - (sectionInset * 2 + (columns - 1) * itemSpacing)) / columns
        return CGSize(width: itemSize, height: itemSize)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        itemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: sectionInset, bottom: 0, right: sectionInset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 50)
    }
}

// MARK: - UITextFieldDelegate

extension NewTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
