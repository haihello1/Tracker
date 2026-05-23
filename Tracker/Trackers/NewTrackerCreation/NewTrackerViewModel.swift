import Foundation

struct CellModel {
    let title: String
    let subtitle: String?
    let type: CellContent
}

final class NewTrackerViewModel {

    var onScheduleUpdated: ((IndexPath) -> Void)?
    var onFormValidChanged: ((Bool) -> Void)?


    private(set) var selectedSchedule: [WeekDay] = []

    private var settingsList: [CellModel] = [
        CellModel(title: "Категория", subtitle: "Влажное", type: .chevron),
        CellModel(title: "Расписание", subtitle: nil, type: .chevron)
    ]

    private var trackerName: String = ""


    var numberOfSettingsSections: Int {
        settingsList.count
    }

    func cellModel(forRowAt indexPath: IndexPath) -> CellModel {
        settingsList[indexPath.row]
    }

    func updateTrackerName(_ name: String) {
        trackerName = name
        notifyFormValidChanged()
    }

    func updateSchedule(with days: [WeekDay]) {
        selectedSchedule = days

        let subtitle = makeScheduleSubtitle(from: days)
        settingsList[1] = CellModel(title: "Расписание", subtitle: subtitle, type: .chevron)

        let indexPath = IndexPath(row: 1, section: 0)
        onScheduleUpdated?(indexPath)

        notifyFormValidChanged()
    }

    func buildTracker() -> Tracker {
        let color = TrackerColor.allCases.randomElement()!
        return Tracker(
            id: UUID(),
            name: trackerName,
            color: color,
            emoji: "😩",
            schedule: selectedSchedule
        )
    }


    private var isFormValid: Bool {
        let hasText = !trackerName.trimmingCharacters(in: .whitespaces).isEmpty
        let hasSchedule = !selectedSchedule.isEmpty
        return hasText && hasSchedule
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
