import UIKit
import Flutter
import flutter_phone_lib
import Intents

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let logger = Logger()
    private let flutterSharedPreferences = FlutterSharedPreferences()
    private var segment: Segment?

    override func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        addOnMissedCallNotificationPressedDelegate()

        return super.application(application, willFinishLaunchingWithOptions: launchOptions)
    }

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let registerPlugins = GeneratedPluginRegistrant.register
        registerPlugins(self)

        if (segment == nil) {
            segment = Segment(logger: self.logger, prefs: self.flutterSharedPreferences)
            segment?.initialize()
        }

        let middleware = Middleware(logger: self.logger, segment: self.segment!)

        startPhoneLib(
            registerPlugins,
            nativeMiddleware: middleware,
            onCallEnded: { (call) in
                self.segment?.track(event: "voip-call-ended", properties: [
                    "call_id" : middleware.currentCallInfo?.callId ?? "",
                    "correlation_id" : middleware.currentCallInfo?.correlationId ?? "",
                    "push_received_time" : middleware.currentCallInfo?.pushReceivedTime ?? "",
                    "reason" : call.reason,
                    "direction" : call.direction,
                    "duration" : call.duration,
                    "mos" : call.mos,
                ])

                middleware.currentCallInfo = nil
            }
        ) { message, level in
            self.logger.writeLog(message)
        }

        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        ContactSortHostApiSetup(controller.binaryMessenger, ContactSortApi())
        NativeLoggingSetup(controller.binaryMessenger, logger)
        NativeMetricsSetup(controller.binaryMessenger, Metrics())
        CallScreenBehaviorSetup(controller.binaryMessenger, CallScreenBehaviorApi())

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    /// Handles receiving call starts from outside the application (e.g. contacts)
    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let handle = userActivity.startCallHandle {
            let number = handle.replacingOccurrences(of: "[^0-9\\+]", with: "", options: .regularExpression)
            startCall(number: number)
        }
        
        return true
    }
}

protocol SupportedStartCallIntent {
    var contacts: [INPerson]? { get }
}

extension INStartAudioCallIntent: SupportedStartCallIntent {}

extension NSUserActivity {
    var startCallHandle: String? {
        guard let startCallIntent = interaction?.intent as? SupportedStartCallIntent else {
            return nil
        }
        return startCallIntent.contacts?.first?.personHandle?.value
    }
}
