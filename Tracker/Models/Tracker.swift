import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: TrackerColor
    let emoji: String
    let schedule: [WeekDay]
}

struct TrackerCategory {
    let title: String
    let trackerCollection: [Tracker]
}

struct TrackerRecord: Hashable {
    let id: UUID
    let date: Date
}

struct GeometricParams {
    let cellCount: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat

    let paddingWidth: CGFloat
    
    init(cellCount: Int, leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat) {
        self.cellCount = cellCount
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.cellSpacing = cellSpacing
        self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
    }
}

enum TrackerColor: String, CaseIterable {
    case red = "#FD4C49"
    case orange = "#FF881E"
    case blue = "#007BFA"
    case purple = "#6E44FE"
    case green = "#33CF69"
    case pink = "#E66DD4"
    case lightPink = "#F9D4D4"
    case lightBlue = "#34A7FE"
    case mint = "#46E69D"
    case indigo = "#35347C"
    case coral = "#FF674D"
    case bubblegum = "#FF99CC"
    case peach = "#F6C48B"
    case periwinkle = "#7994F5"
    case violet = "#832CF1"
    case orchid = "#AD56DA"
    case lavender = "#8D72E6"
    case limeGreen = "#2FD058"

    var uiColor: UIColor {
        UIColor(hex: rawValue)
    }
}

struct TrackerCellViewModel {
    let emoji: String
    let title: String
    let color: TrackerColor
    let isCompleted: Bool
    let completedDays: Int
}
