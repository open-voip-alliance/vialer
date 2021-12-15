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
abstract class NativeIncomingCallScreen {
  void launch(
    String remotePartyHeading,
    String remotePartySubheading,
  );
}

@HostApi()
// ignore:one_member_abstracts
abstract class NativeMetrics {
  void initialize(String key);
}
