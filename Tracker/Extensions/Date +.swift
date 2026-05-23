import Foundation

extension Date {
    var isFutureDay: Bool {
        let calendar = Calendar.current

        let today = calendar.startOfDay(for: Date())
        let selected = calendar.startOfDay(for: self)

        return selected > today
    }
}
