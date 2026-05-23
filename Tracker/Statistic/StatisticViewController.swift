import UIKit


final class StatisticViewController: UIViewController {

    private lazy var sectionNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Статистика"
        lbl.font = .ypBold34
        return lbl
    }()
    
    private lazy var emptyView: EmptyView = {
        let ev = EmptyView()
        ev.configure(text: "Пока нечего анализировать", image: UIImage(resource: .emptyStatisticView))
        return ev
    }()
        
    override func viewDidLoad() {
        setUI()
        setConstraints()
    }
    
    private func setUI() {
        view.addSubviews(sectionNameLabel, emptyView)
        view.backgroundColor = .appWhite
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            sectionNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppLayout.horizontalSpacing),
            sectionNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.topAnchor.constraint(equalTo: sectionNameLabel.bottomAnchor, constant: 8),
            emptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
