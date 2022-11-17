import '../../vialer.dart';

class NoTemporaryRedirectSetupException extends VialerException {}

class NoClientException extends VialerException {}

class UnableToRedirectToUnknownDestination extends ArgumentError {
  UnableToRedirectToUnknownDestination()
      : super(
          'Unable to set-up a temporary redirect to an unknown destination.',
        );
}
