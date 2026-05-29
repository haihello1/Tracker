import Foundation
import os.log

final class CategoryViewModel {

    var onCategoriesUpdated: (() -> Void)?
    var onCategorySelected: ((String) -> Void)?
    var onDismiss: (() -> Void)?

    private(set) var categories: [String] = [] {
        didSet { onCategoriesUpdated?() }
    }

    private(set) var selectedCategory: String?

    private let categoryStore: TrackerCategoryStore

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "CategoryViewModel",
        category: "CategoryViewModel"
    )

    init(categoryStore: TrackerCategoryStore, selectedCategory: String?) {
        self.categoryStore = categoryStore
        self.selectedCategory = selectedCategory

        categoryStore.addObserver { [weak self] in
            self?.loadCategories()
        }

        loadCategories()
    }

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
        do {
            try categoryStore.addCategory(title: name)
        } catch {
            logger.error("Failed to add category '\(name)': \(error.localizedDescription)")
        }
    }

    func editCategory(oldTitle: String, newTitle: String) {
        do {
            try categoryStore.updateCategory(oldTitle: oldTitle, newTitle: newTitle)
        } catch {
            logger.error("Failed to update category '\(oldTitle)' -> '\(newTitle)': \(error.localizedDescription)")
        }
    }

    func deleteCategory(title: String) {
        do {
            try categoryStore.deleteCategory(title: title)
        } catch {
            logger.error("Failed to delete category '\(title)': \(error.localizedDescription)")
        }
    }

    func isSelected(_ title: String) -> Bool {
        title == selectedCategory
    }
}
