import UIKit

final class TrackersViewController: UIViewController {


    private let viewModel: TrackersViewModel
    private let params: GeometricParams


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
        label.text = "Трекеры"
        label.font = .ypBold34
        return label
    }()

    private lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Поиск"
        sb.backgroundImage = UIImage()
        sb.delegate = self
        return sb
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
        return cv
    }()


    init(viewModel: TrackersViewModel, using params: GeometricParams) {
        self.viewModel = viewModel
        self.params = params
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavBar()
        setupConstraints()
        bindViewModel()
        showEmptyView(
            text: "Что будем отслеживать?",
            image: UIImage(resource: .emptyTrackersView)
        )
        viewModel.viewDidLoad()
    }


    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self else { return }
            switch state {
            case .content:
                self.showTrackersCollection()
                self.trackerCollection.reloadData()
            case .empty:
                self.showEmptyView(
                    text: "Что будем отслеживать?",
                    image: UIImage(resource: .emptyTrackersView)
                )
                
            case .noResultsFound:
                self.showEmptyView(
                    text: "Ничего не найдено",
                    image: UIImage(resource: .noTrackersFound)
                )
            }
        }

        viewModel.onDataUpdated = { [weak self] in
            self?.trackerCollection.reloadData()
        }
    }


    private func showEmptyView(text: String, image: UIImage) {
        trackerCollection.isHidden = true
        emptyView.isHidden = false
        emptyView.configure(text: text, image: image)
    }

    private func showTrackersCollection() {
        emptyView.isHidden = true
        trackerCollection.isHidden = false
    }


    private func setupUI() {
        view.backgroundColor = .appWhite
        view.addSubviews(sectionNameLabel, searchBar, emptyView, trackerCollection)
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
        ])
    }

    @objc private func didTapAddButton() {
        viewModel.didTapAddTrackersButton()
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        viewModel.didSelectDate(sender.date)
    }
}


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


extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems(in: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseID, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        let model = viewModel.cellViewModel(at: indexPath)
        cell.configure(with: model)
        cell.onCompleteButtonTapped = { [weak self] in
            self?.viewModel.didToggleCompletion(at: indexPath)

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


extension TrackersViewController: UICollectionViewDelegate {}


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
