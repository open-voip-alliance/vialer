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
