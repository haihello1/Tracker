import Foundation

final class CategoryViewModel {

    // MARK: - Bindings

    var onCategoriesUpdated: (() -> Void)?
    var onCategorySelected: ((String) -> Void)?
    var onDismiss: (() -> Void)?

    // MARK: - Output

    private(set) var categories: [String] = [] {
        didSet { onCategoriesUpdated?() }
    }

    private(set) var selectedCategory: String?

    // MARK: - Private

    private let categoryStore: TrackerCategoryStore

    // MARK: - Init

    init(categoryStore: TrackerCategoryStore, selectedCategory: String?) {
        self.categoryStore = categoryStore
        self.selectedCategory = selectedCategory

        // Подписываемся ДО первой загрузки, чтобы не пропустить обновления
        categoryStore.onDataChanged = { [weak self] in
            self?.loadCategories()
        }

        loadCategories()
    }

    // MARK: - Public Interface

    func loadCategories() {
        categories = categoryStore.categories.map { $0.title }
    }

    func selectCategory(at index: Int) {
        guard index < categories.count else { return }
        let title = categories[index]
        selectedCategory = title
        onCategorySelected?(title)
        onDismiss?()
    }

    func addCategory(name: String) {
        try? categoryStore.addCategory(title: name)
    }

    func editCategory(oldTitle: String, newTitle: String) {
        try? categoryStore.updateCategory(oldTitle: oldTitle, newTitle: newTitle)
    }

    func deleteCategory(title: String) {
        try? categoryStore.deleteCategory(title: title)
    }

    func isSelected(_ title: String) -> Bool {
        title == selectedCategory
    }
}
