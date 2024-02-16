import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vialer/presentation/util/contact.dart';

part 'shared_contact.freezed.dart';
part 'shared_contact.g.dart';

@freezed
class SharedContact with _$SharedContact {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SharedContact({
    required String? id,
    String? givenName,
    String? familyName,
    String? companyName,
    @Default([]) List<SharedContactPhoneNumber> phoneNumbers,
  }) = _SharedContact;

  factory SharedContact.fromJson(Map<String, dynamic> json) =>
      _$SharedContactFromJson(json);

  const SharedContact._();

  String get _fullName =>
      [givenName, familyName].whereNotNullOrBlank().join(' ').trim();

  /// This will append the company name with brackets at the end to make the
  /// contact names shown in the app match the contact name shown in the web
  /// phone.
  String get displayName {
    if (_fullName.isNotNullOrBlank) {
      return companyName.isNotNullOrBlank
          ? '$_fullName ($companyName)'
          : _fullName;
    }

    return companyName.isNotNullOrBlank ? companyName! : '';
  }

  /// We might not want the full display name as it will contain brackets with
  /// the company name. This will just return the most basic form of it, not
  /// including the company name at all unless there is no personal name set.
  String get simpleDisplayName {
    if (_fullName.isNotNullOrBlank) {
      return _fullName;
    }

    return companyName.isNotNullOrBlank ? companyName! : '';
  }
}

@freezed
class SharedContactPhoneNumber with _$SharedContactPhoneNumber {
  const SharedContactPhoneNumber._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SharedContactPhoneNumber({
    required String phoneNumberFlat,
    String? phoneNumberPretty,
    String? callingCode,
  }) = _SharedContactPhoneNumber;

  factory SharedContactPhoneNumber.fromJson(Map<String, dynamic> json) =>
      _$SharedContactPhoneNumberFromJson(json);

  String get withoutCallingCode =>
      phoneNumberFlat.replaceFirst('+${callingCode}', '0');
}
