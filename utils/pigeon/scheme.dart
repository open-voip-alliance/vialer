import 'package:pigeon/pigeon.dart';

enum OrderBy {
  givenName,
  familyName,
}

class ContactSort {
  OrderBy? orderBy;
}

@HostApi()
// ignore:one_member_abstracts
abstract class ContactSortHostApi {
  ContactSort getSorting();
}

class NativePhoneNumber {
  String phoneNumberFlat;
  String phoneNumberWithoutCallingCode;

  NativePhoneNumber({
    required this.phoneNumberFlat,
    required this.phoneNumberWithoutCallingCode,
  });
}

class NativeSharedContact {
  List<NativePhoneNumber?> phoneNumbers;
  String displayName;

  NativeSharedContact({required this.phoneNumbers, required this.displayName});
}

@HostApi()
// ignore:one_member_abstracts
abstract class SharedContacts {
  void processSharedContacts(List<NativeSharedContact> contacts);

  /// Check if Vialer is currently set a call identification app, which means
  /// the call directory extension has been enabled.
  @async
  bool isCallDirectoryExtensionEnabled();

  /// Will direct the user to iOS settings, as close as possible to the page
  /// where the user can set Vialer as a call identification app. The exact
  /// place this directs to may differ depending on iOS version.
  void directUserToConfigureCallDirectoryExtension();
}

/// Allow logging to be performed natively, this allows us to bypass the
/// conversion from native to Dart and the associated overhead.
@HostApi()
// ignore:one_member_abstracts
abstract class NativeLogging {
  @async
  void startNativeRemoteLogging(
    String token,
    String userIdentifier,
    Map<String, String> anonymizationRules,
  );

  void startNativeConsoleLogging();

  void stopNativeRemoteLogging();

  void stopNativeConsoleLogging();
}

@HostApi()
// ignore:one_member_abstracts
abstract class NativeIncomingCallScreen {
  void launch(
    String remotePartyHeading,
    String remotePartySubheading,
    String imageUri,
  );
}

@HostApi()
// ignore:one_member_abstracts
abstract class NativeMetrics {
  void initialize();
}

@HostApi()
abstract class CallScreenBehavior {
  void enable();
  void disable();
}

@HostApi()
// ignore:one_member_abstracts
abstract class Tones {
  void playForDigit(String digit);
}

@HostApi()
abstract class AppUpdates {
  void check();
  void completeAndroidFlexibleUpdate();
}

@FlutterApi()
abstract class AndroidFlexibleUpdateHandler {
  // ignore: avoid_positional_boolean_parameters
  void onUpdateTypeKnown(bool isFlexible);
  void onDownloaded();
}

@HostApi()
// ignore:one_member_abstracts
abstract class CallThrough {
  void startCall(String number);
}

@HostApi()
// ignore: one_member_abstracts
abstract class Contacts {
  @async
  void importContacts(String cacheFilePath);
  @async
  void importContactAvatars(String avatarDirectoryPath);
}

@HostApi()
abstract class GooglePlayServices {
  bool isAvailable();
}

@HostApi()
abstract class MiddlewareRegistrar {
  void register(String token);
}

@FlutterApi()
abstract class NativeToFlutter {
  void launchDialerAndPopulateNumber(String number);
}

@HostApi()
// ignore: one_member_abstracts
abstract class NativeClipboard {
  @async
  bool hasPhoneNumber();
}
