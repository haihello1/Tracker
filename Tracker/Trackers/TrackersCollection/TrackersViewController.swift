import UIKit

final class TrackersViewController: UIViewController {

    private let viewModel: TrackersViewModel
    private let params: GeometricParams
    weak var coordinator: TrackersCoordinatorProtocol?

    private lazy var emptyView = EmptyView()

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return picker
    }()

    private lazy var sectionNameLabel: UILabel = {
        let label = UILabel()
        label.text = "trackers_title".localized
        label.font = .ypBold34
        return label
    }()

    private lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "search_placeholder".localized
        sb.backgroundImage = UIImage()
        sb.delegate = self
        return sb
    }()

    private lazy var filtersButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "filters_button".localized
        config.background.cornerRadius = AppLayout.cornerRadius
        config.baseBackgroundColor = .appBlue
        config.baseForegroundColor = .appWhite
        let btn = UIButton(configuration: config)
        btn.addTarget(self, action: #selector(didTapFiltersButton), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var trackerCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseID)
        cv.register(
            HeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HeaderView.reuseID
        )
        cv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        return cv
    }()

    init(viewModel: TrackersViewModel, using params: GeometricParams) {
        self.viewModel = viewModel
        self.params = params
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavBar()
        setupConstraints()
        bindViewModel()
        showEmptyView(
            text: "empty_trackers_text".localized,
            image: UIImage(resource: .emptyTrackersView)
        )
        viewModel.viewDidLoad()
        AnalyticsService.report(
            event: AnalyticsService.Event.open,
            screen: AnalyticsService.Screen.main
        )
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.report(
            event: AnalyticsService.Event.close,
            screen: AnalyticsService.Screen.main
        )
    }

    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self else { return }
            switch state {
            case .content:
                self.showTrackersCollection()
            case .empty:
                self.filtersButton.isHidden = true
                self.showEmptyView(
                    text: "empty_trackers_text".localized,
                    image: UIImage(resource: .emptyTrackersView)
                )
            case .noResultsFound:
                self.filtersButton.isHidden = !self.viewModel.hasTrackersForCurrentDay
                self.showEmptyView(
                    text: "empty_search_text".localized,
                    image: UIImage(resource: .noTrackersFound)
                )
            }
        }

        viewModel.onDataUpdated = { [weak self] in
            guard let self else { return }
            self.trackerCollection.reloadData()
            let hasTrackersForDay = self.viewModel.hasTrackersForCurrentDay
            self.filtersButton.isHidden = !hasTrackersForDay
            if self.viewModel.numberOfSections > 0 {
                self.showTrackersCollection()
            }
        }

        viewModel.onDateChanged = { [weak self] date in
            self?.datePicker.date = date
        }
    }

    private func showEmptyView(text: String, image: UIImage) {
        trackerCollection.isHidden = true
        filtersButton.isHidden = true
        emptyView.isHidden = false
        emptyView.configure(text: text, image: image)
    }

    private func showTrackersCollection() {
        emptyView.isHidden = true
        trackerCollection.isHidden = false
        filtersButton.isHidden = false
    }

    private func setupUI() {
        view.backgroundColor = .appWhite
        view.addSubviews(sectionNameLabel, searchBar, emptyView, trackerCollection, filtersButton)
    }

    private func setupNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(resource: .addTrackerBtn),
            style: .plain,
            target: self,
            action: #selector(didTapAddButton)
        )
        navigationItem.leftBarButtonItem?.tintColor = .appBlack
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            sectionNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppLayout.horizontalSpacing),
            sectionNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.topAnchor.constraint(equalTo: sectionNameLabel.bottomAnchor, constant: 7),

            trackerCollection.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            trackerCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackerCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackerCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            emptyView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.widthAnchor.constraint(equalToConstant: 114)
        ])
    }

    @objc private func didTapAddButton() {
        AnalyticsService.report(
            event: AnalyticsService.Event.click,
            screen: AnalyticsService.Screen.main,
            item: AnalyticsService.Item.addTrack
        )
        viewModel.didTapAddTrackersButton()
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        viewModel.didSelectDate(sender.date)
    }

    @objc private func didTapFiltersButton() {
        AnalyticsService.report(
            event: AnalyticsService.Event.click,
            screen: AnalyticsService.Screen.main,
            item: AnalyticsService.Item.filter
        )
        let filterVC = FilterViewController(selectedFilter: viewModel.currentFilter)
        filterVC.delegate = self
        let nav = UINavigationController(rootViewController: filterVC)
        present(nav, animated: true)
    }
}

// MARK: - FilterViewControllerDelegate

extension TrackersViewController: FilterViewControllerDelegate {
    func didSelectFilter(_ filter: TrackerFilter) {
        viewModel.didSelectFilter(filter)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - params.paddingWidth) / CGFloat(params.cellCount)
        return CGSize(width: width, height: width * 0.9)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let spacing = AppLayout.horizontalSpacing
        return UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 40)
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems(in: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseID,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }

        let model = viewModel.cellViewModel(at: indexPath)
        cell.configure(with: model)

        cell.onCompleteButtonTapped = { [weak self, weak cell] in
            guard let self, let cell,
                  let currentIndexPath = self.trackerCollection.indexPath(for: cell)
            else { return }
            AnalyticsService.report(
                event: AnalyticsService.Event.click,
                screen: AnalyticsService.Screen.main,
                item: AnalyticsService.Item.track
            )
            self.viewModel.didToggleCompletion(at: currentIndexPath)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HeaderView.reuseID,
                for: indexPath
              ) as? HeaderView
        else {
            return UICollectionReusableView()
        }
        header.configure(headerTitle: viewModel.categoryTitle(for: indexPath.section))
        return header
    }
}

// MARK: - UICollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self else { return UIMenu(title: "", children: []) }

            let editAction = UIAction(title: "Редактировать") { [weak self] _ in
                guard let self else { return }
                AnalyticsService.report(
                    event: AnalyticsService.Event.click,
                    screen: AnalyticsService.Screen.main,
                    item: AnalyticsService.Item.edit
                )
                let (tracker, categoryTitle, completedDays) = self.viewModel.trackerAndCategory(at: indexPath)
                self.coordinator?.openEditTrackerFlow(
                    tracker: tracker,
                    categoryTitle: categoryTitle,
                    completedDays: completedDays
                )
            }

            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                guard let self else { return }
                AnalyticsService.report(
                    event: AnalyticsService.Event.click,
                    screen: AnalyticsService.Screen.main,
                    item: AnalyticsService.Item.delete
                )
                self.showDeleteConfirmation(for: indexPath)
            }

            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}

// MARK: - UISearchBarDelegate

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.didChangeSearchQuery(searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        viewModel.didChangeSearchQuery("")
    }
}

// MARK: - Private helpers

private extension TrackersViewController {

    func showDeleteConfirmation(for indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Уверены что хотите удалить трекер?",
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteTracker(at: indexPath)
        })
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        present(alert, animated: true)
    }
}
