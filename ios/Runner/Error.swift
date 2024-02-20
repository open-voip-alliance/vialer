// Required by Pigeon, see: https://github.com/flutter/flutter/issues/137057

import Foundation

import Foundation
#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#else
#error("Unsupported platform.")
#endif


extension FlutterError: Swift.Error {}
