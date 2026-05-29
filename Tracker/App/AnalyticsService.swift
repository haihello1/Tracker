import AppMetricaCore

final class AnalyticsService {

    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "API_KEY") else { return }
        AppMetrica.activate(with: configuration)
    }

    static func report(event: String, screen: String, item: String? = nil) {
        var params: [AnyHashable: Any] = [
            "event": event,
            "screen": screen
        ]
        if let item {
            params["item"] = item
        }

        AppMetrica.reportEvent(name: event, parameters: params) { error in
            print("AppMetrica report error: \(error.localizedDescription)")
        }

        print("Analytics — event: \(event), screen: \(screen), item: \(item ?? "—")")
    }
}

// MARK: - Constants

extension AnalyticsService {
    enum Event {
        static let open = "open"
        static let close = "close"
        static let click = "click"
    }

    enum Screen {
        static let main = "Main"
    }

    enum Item {
        static let addTrack = "add_track"
        static let track = "track"
        static let filter = "filter"
        static let edit = "edit"
        static let delete = "delete"
    }
}
