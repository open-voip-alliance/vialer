import UIKit
import Flutter
import flutter_phone_lib

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let logger = Logger()
    
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

        startPhoneLib(registerPlugins) { message, level in
            self.logger.writeLog(message)
        }

        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        NativeLoggingSetup(controller.binaryMessenger, logger)
        ContactSortHostApiSetup(controller.binaryMessenger, ContactSortApi())
        NativeMetricsSetup(controller.binaryMessenger, Metrics())
        CallScreenBehaviorSetup(controller.binaryMessenger, CallScreenBehaviorApi())
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
