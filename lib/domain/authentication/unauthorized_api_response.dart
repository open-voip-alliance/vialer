/// An unauthorized (typically 401) response was received when attempting to
/// contact the API.
class UnauthorizedApiResponseEvent {
  /// The status code that caused the user to appear as unauthorized.
  final int statusCode;

  const UnauthorizedApiResponseEvent(this.statusCode);
}
