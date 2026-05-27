import Foundation

struct CellModel {
    let title: String
    let subtitle: String?
    let type: CellContent
}

final class NewTrackerViewModel {

    var onScheduleUpdated: ((IndexPath) -> Void)?
    var onFormValidChanged: ((Bool) -> Void)?

    private(set) var selectedCategory: String?
    private(set) var selectedSchedule: [WeekDay] = []
    private(set) var selectedEmoji: String?
    private(set) var selectedColor: TrackerColor?

    let emojis: [String] = [
        "🙂","😻","🌺","🐶","❤️","😱",
        "😇","😡","🥶","🤔","🙌","🍔",
        "🥦","🏓","🥇","🎸","🏄","😪"
    ]

    let colors: [TrackerColor] = TrackerColor.allCases

    private var settingsList: [CellModel] = [
        CellModel(title: "Категория", subtitle: nil, type: .chevron),
        CellModel(title: "Расписание", subtitle: nil, type: .chevron)
    ]

    private var trackerName: String = ""

    var numberOfSettingsSections: Int { settingsList.count }

    func cellModel(forRowAt indexPath: IndexPath) -> CellModel {
        settingsList[indexPath.row]
    }

    func updateTrackerName(_ name: String) {
        trackerName = name
        notifyFormValidChanged()
    }

    func selectEmoji(_ emoji: String) {
        selectedEmoji = emoji
        notifyFormValidChanged()
    }

    func selectColor(_ color: TrackerColor) {
        selectedColor = color
        notifyFormValidChanged()
    }

    func updateCategory(with category: String) {
        selectedCategory = category
        settingsList[0] = CellModel(title: "Категория", subtitle: category, type: .chevron)
        onScheduleUpdated?(IndexPath(row: 0, section: 0))
        notifyFormValidChanged()
    }

    func updateSchedule(with days: [WeekDay]) {
        selectedSchedule = days
        let subtitle = makeScheduleSubtitle(from: days)
        settingsList[1] = CellModel(title: "Расписание", subtitle: subtitle, type: .chevron)
        onScheduleUpdated?(IndexPath(row: 1, section: 0))
        notifyFormValidChanged()
    }

    func buildTracker() -> Tracker {
        return Tracker(
            id: UUID(),
            name: trackerName,
            color: selectedColor ?? .red,
            emoji: selectedEmoji ?? "😊",
            schedule: selectedSchedule
        )
    }

    private var isFormValid: Bool {
        let hasText = !trackerName.trimmingCharacters(in: .whitespaces).isEmpty
        let hasCategory = selectedCategory != nil
        let hasSchedule = !selectedSchedule.isEmpty
        let hasEmoji = selectedEmoji != nil
        let hasColor = selectedColor != nil
        return hasText && hasCategory && hasSchedule && hasEmoji && hasColor
    }

    private func notifyFormValidChanged() {
        onFormValidChanged?(isFormValid)
    }

    private func makeScheduleSubtitle(from days: [WeekDay]) -> String? {
        switch days.count {
        case 0: return nil
        case 7: return "Каждый день"
        default: return days.map { $0.prefix }.joined(separator: ", ")
        }
    }
}
