// Since CallScreenBehaviorApi is only necessary on Android it's not implemented here.
// Only provide the empty class and functions so it won't generate a Pigeon channel-error.
class CallScreenBehaviorApi: NSObject, CallScreenBehavior {
    func enableWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {}
    
    func disableWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {}
}
