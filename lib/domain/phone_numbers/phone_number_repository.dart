import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:vialer/app/util/loggable.dart';
import 'package:vialer/domain/phone_numbers/phone_number_service.dart';

part 'phone_number_repository.freezed.dart';

part 'phone_number_repository.g.dart';

@singleton
class PhoneNumberRepository with Loggable {
  PhoneNumberRepository(this._service);

  final PhoneNumberService _service;

  Future<ValidationResult> validate(String number) async {
    final httpResponse = await _service.validate(number);

    if (httpResponse.statusCode == 400) {
      return ValidationResult.invalid();
    }

    if (!httpResponse.isSuccessful) {
      logFailedResponse(httpResponse, name: 'Validate phone number');
      return ValidationResult.invalid();
    }

    final response =
        _PhoneNumberValidationResponse.fromJson(httpResponse.body!);

    return response.toValidationResult();
  }
}

@freezed
class _PhoneNumberValidationResponse with _$_PhoneNumberValidationResponse {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory _PhoneNumberValidationResponse({
    // These properties are only used when creating via JSON.
    // ignore_for_file: unused_element
    required bool isValid,
    String? phoneNumberPretty,
    String? phoneNumberFlat,
    String? phoneNumberType,
    String? callingCode,
    String? countryCode,
    String? location,
  }) = __PhoneNumberValidationResponse;

  factory _PhoneNumberValidationResponse.fromJson(Map<String, dynamic> json) =>
      _$_PhoneNumberValidationResponseFromJson(json);
}

@freezed
sealed class ValidationResult with _$ValidationResult {
  const factory ValidationResult.valid({
    required String pretty,
    required String flat,
    required PhoneNumberType type,
    required String callingCode,
    required String countryCode,
    required String location,
  }) = ValidPhoneNumberResult;
  const factory ValidationResult.invalid() = InvalidPhoneNumberResult;
}

extension on _PhoneNumberValidationResponse {
  ValidationResult toValidationResult() {
    if (!this.isValid) return ValidationResult.invalid();

    return ValidationResult.valid(
      pretty: phoneNumberPretty!,
      flat: phoneNumberFlat!,
      type: PhoneNumberType.fromServerValue(phoneNumberType!),
      callingCode: callingCode!,
      countryCode: countryCode!,
      location: location!,
    );
  }
}

enum PhoneNumberType {
  mobile,
  internal,
  fixed,
  unknown;

  static PhoneNumberType fromServerValue(String value) => switch (value) {
        'Mobile' => mobile,
        'Internal' => internal,
        'Fixed' => fixed,
        _ => unknown,
      };
}
