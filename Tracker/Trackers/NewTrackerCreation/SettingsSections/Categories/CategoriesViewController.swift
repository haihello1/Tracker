import UIKit

final class CategoryViewController: UIViewController {

    // MARK: - Dependencies

    private let viewModel: CategoryViewModel

    // MARK: - UI

    private let menuScrollContainer = UIScrollView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyView = EmptyView()
    private let addButton = UIButton(type: .system)

    private var tableHeightConstraint: NSLayoutConstraint?

    // MARK: - Init

    init(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bindViewModel()
    }

    // MARK: - Bindings

    private func bindViewModel() {
        // ViewModel уже загрузила данные в init через loadCategories().
        // Здесь только подписываемся на будущие обновления — лишний вызов updateView убран.
        viewModel.onCategoriesUpdated = { [weak self] in
            self?.updateView()
        }
        // Первичная отрисовка — вызываем явно один раз
        updateView()
    }

    // MARK: - State Update

    private func updateView() {
        let isEmpty = viewModel.categories.isEmpty
        menuScrollContainer.isHidden = isEmpty
        emptyView.isHidden = !isEmpty

        if isEmpty {
            emptyView.configure(
                text: "Привычки и события можно\nобъединить по смыслу",
                image: UIImage(resource: .emptyTrackersView)
            )
        } else {
            tableHeightConstraint?.constant = CGFloat(viewModel.categories.count) * AppLayout.menuCellHeight
        }

        tableView.reloadData()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .appWhite
        navigationItem.title = "Категория"
        navigationItem.hidesBackButton = true

        menuScrollContainer.showsVerticalScrollIndicator = false
        menuScrollContainer.translatesAutoresizingMaskIntoConstraints = false

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.reuseID)
        tableView.layer.cornerRadius = AppLayout.cornerRadius
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = .appGray.withAlphaComponent(0.3)
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .appBackground
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.translatesAutoresizingMaskIntoConstraints = false

        var config = UIButton.Configuration.filled()
        config.title = "Добавить категорию"
        config.background.cornerRadius = AppLayout.cornerRadius
        config.baseBackgroundColor = .appBlack
        config.baseForegroundColor = .appWhite
        addButton.configuration = config
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false

        menuScrollContainer.addSubview(tableView)
        view.addSubviews(menuScrollContainer, emptyView, addButton)
    }

    private func setupConstraints() {
        let initialHeight = CGFloat(viewModel.categories.count) * AppLayout.menuCellHeight
        let heightConstraint = tableView.heightAnchor.constraint(equalToConstant: initialHeight)
        tableHeightConstraint = heightConstraint

        NSLayoutConstraint.activate([
            menuScrollContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            menuScrollContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            menuScrollContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            menuScrollContainer.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -24),

            tableView.topAnchor.constraint(equalTo: menuScrollContainer.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: menuScrollContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: menuScrollContainer.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: menuScrollContainer.bottomAnchor),
            tableView.widthAnchor.constraint(equalTo: menuScrollContainer.widthAnchor),
            heightConstraint,

            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - Actions

    @objc private func addButtonTapped() {
        let vc = CategoryEditViewController(mode: .create) { [weak self] name in
            self?.viewModel.addCategory(name: name)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func editCategory(title: String) {
        let vc = CategoryEditViewController(mode: .edit(currentTitle: title)) { [weak self] newName in
            self?.viewModel.editCategory(oldTitle: title, newTitle: newName)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func deleteCategory(title: String) {
        let alert = UIAlertController(
            title: "Эта категория точно не нужна?",
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(title: title)
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MenuCell.reuseID,
            for: indexPath
        ) as? MenuCell else {
            return UITableViewCell()
        }

        let title = viewModel.categories[indexPath.row]
        let isSelected = viewModel.isSelected(title)
        let model = CellModel(title: title, subtitle: nil, type: .checkmark(isSelected))
        cell.configure(with: model)

        let isLast = indexPath.row == viewModel.categories.count - 1
        cell.separatorInset = isLast
            ? UIEdgeInsets(top: 0, left: 1000, bottom: 0, right: 0)
            : UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        AppLayout.menuCellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectCategory(at: indexPath.row)
        tableView.reloadData()
    }

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let category = viewModel.categories[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let editAction = UIAction(title: "Редактировать") { _ in
                self?.editCategory(title: category)
            }
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
                self?.deleteCategory(title: category)
            }
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}
