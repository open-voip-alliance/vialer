import 'package:freezed_annotation/freezed_annotation.dart';

part 'unauthorized_api_response.freezed.dart';

/// An unauthorized (typically 401) response was received when attempting to
/// contact the API.
@freezed
class UnauthorizedApiResponseEvent with _$UnauthorizedApiResponseEvent {
  const factory UnauthorizedApiResponseEvent(
    /// The status code that caused the user to appear as unauthorized.
    int statusCode,
  ) = _UnauthorizedApiResponseEvent;
}
