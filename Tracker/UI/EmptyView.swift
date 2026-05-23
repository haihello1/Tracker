import UIKit


final class EmptyView: UIView {
    
    private var noTrackersFoundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(resource: .emptyTrackersView)
        return iv
    }()
    
    private var noTrackersFoundLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12)
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        

        addSubviews(noTrackersFoundImageView, noTrackersFoundLabel)
        
        NSLayoutConstraint.activate([
            noTrackersFoundImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            noTrackersFoundImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            noTrackersFoundLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            noTrackersFoundLabel.topAnchor.constraint(equalTo: noTrackersFoundImageView.bottomAnchor, constant: 8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String, image: UIImage) {
        noTrackersFoundLabel.text = text
        noTrackersFoundImageView.image = image
    }
}


