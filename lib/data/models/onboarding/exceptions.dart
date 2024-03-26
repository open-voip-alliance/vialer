import '../vialer.dart';

class NeedToChangePasswordException extends VialerException {}

class FailedToRetrieveUserException extends VialerException {
  int? statusCode;
  String? error;
  FailedToRetrieveUserException({
    this.statusCode,
    this.error,
  });

  @override
  String toString() =>
      'FailedToRetrieveUserException: $error with error code: $statusCode';
}
