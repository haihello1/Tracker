import Foundation

final class WeekDayTransformer: ValueTransformer {

    override class func transformedValueClass() -> AnyClass {
        NSArray.self
    }

    override class func allowsReverseTransformation() -> Bool {
        true
    }

    // [WeekDay] -> Data
    override func transformedValue(_ value: Any?) -> Any? {
        guard let weekDays = value as? [WeekDay] else { return nil }
        let rawValues = weekDays.map { $0.rawValue }
        return try? JSONEncoder().encode(rawValues)
    }

    // Data -> [WeekDay]
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        let rawValues = try? JSONDecoder().decode([String].self, from: data)
        return rawValues?.compactMap { WeekDay(rawValue: $0) }
    }

    static func register() {
        let transformer = WeekDayTransformer()
        ValueTransformer.setValueTransformer(
            transformer,
            forName: NSValueTransformerName("WeekDayTransformer")
        )
    }
}
