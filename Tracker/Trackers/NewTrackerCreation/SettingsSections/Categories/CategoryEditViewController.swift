import UIKit

final class CategoryEditViewController: UIViewController {
    enum Mode {
        case create
        case edit(currentTitle: String)
    }
    
    private let mode: Mode
    private let onSave: (String) -> Void
    
    private let textField = UITextField()
    private let doneButton = UIButton(type: .system)
    
    init(mode: Mode, onSave: @escaping (String) -> Void) {
        self.mode = mode
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        updateButtonState()
    }
    
    private func setupUI() {
        view.backgroundColor = .appWhite
        
        switch mode {
        case .create:
            navigationItem.title = "Создание категории"
            navigationItem.hidesBackButton = true
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        case .edit(let title):
            navigationItem.title = "Редактировать категории"
            navigationItem.hidesBackButton = true
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            textField.text = title
        }
        
        textField.placeholder = "Введите название категории"
        textField.layer.cornerRadius = AppLayout.cornerRadius
        textField.backgroundColor = .appBackground
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        textField.leftViewMode = .always
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.delegate = self
        
        var config = UIButton.Configuration.filled()
        config.title = "Готово"
        config.background.cornerRadius = AppLayout.cornerRadius
        config.baseBackgroundColor = .appBlack
        config.baseForegroundColor = .appWhite
        doneButton.configuration = config
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
        view.addSubviews(textField, doneButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: AppLayout.menuCellHeight),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func textFieldDidChange() {
        updateButtonState()
    }
    
    private func updateButtonState() {
        let text = textField.text ?? ""
        let isEnabled = !text.trimmingCharacters(in: .whitespaces).isEmpty
        doneButton.isEnabled = isEnabled
        doneButton.configuration?.baseBackgroundColor = isEnabled ? .appBlack : .appBlack.withAlphaComponent(0.3)
    }
    
    @objc private func doneButtonTapped() {
        guard let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        onSave(text)
        navigationController?.popViewController(animated: true)
    }
}

extension CategoryEditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
