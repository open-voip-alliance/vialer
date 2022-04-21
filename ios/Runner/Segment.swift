import Foundation
import Segment

class Segment {

    private var isIdentified = false

    private let logger: Logger
    private let prefs: FlutterSharedPreferences

    init(logger: Logger, prefs: FlutterSharedPreferences) {
        self.logger = logger
        self.prefs = prefs
    }

    func initialize() {
        if (Segment.instance != nil) { return }

        isIdentified = false

        if (Segment.key?.isEmpty != false) {
            logger.writeLog("Unable to initialize metrics, there is no key.")
            return
        }

        let configuration = AnalyticsConfiguration(writeKey: Segment.key!)
        configuration.trackApplicationLifecycleEvents = false
        configuration.recordScreenViews = false
        Analytics.setup(with: configuration)
    }

    func track(event: String, properties: [String : Any]) {
        if (Segment.instance == nil) {
            logger.writeLog("Segment not initialized, logging event: \(event) with properties: \(properties)")
            return
        }

        identifyIfNecessary {
            Analytics.shared().track(event, properties: properties)
        }
    }

    func identifyIfNecessary(_ callback: @escaping () -> Void) {
        if (isIdentified) {
            callback()
            return
        }

        guard let user = prefs.systemUser else {
            logger.writeLog("Unable to identify user for native metrics.")
            return
        }

        guard let userUuid = user["uuid"] as? String else {
            logger.writeLog("Unable to find user uuid for native metrics.")
            return
        }

        Analytics.shared().identify(userUuid)
        isIdentified = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            callback()
        }
    }

    private static var instance: Analytics? = nil
    private static let key = Bundle.main.infoDictionary?["Segment Key"] as? String
}