import UIKit
import Flutter
import flutter_phone_lib

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let registerPlugins = GeneratedPluginRegistrant.register
    registerPlugins(self)

    startPhoneLib(registerPlugins)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
