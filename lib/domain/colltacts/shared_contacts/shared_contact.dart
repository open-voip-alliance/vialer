import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vialer/app/util/contact.dart';

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
    @Default([]) List<SharedContactGroup> groups,
    @Default([]) List<SharedContactVoipAccount> voipAccounts,
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
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SharedContactPhoneNumber({
    bool? isValid,
    String? phoneNumberPretty,
    required String phoneNumberFlat,
    String? phoneNumberType,
    String? callingCode,
    String? countryCode,
    String? location,
  }) = _SharedContactPhoneNumber;

  factory SharedContactPhoneNumber.fromJson(Map<String, dynamic> json) =>
      _$SharedContactPhoneNumberFromJson(json);
}

@freezed
class SharedContactVoipAccount with _$SharedContactVoipAccount {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SharedContactVoipAccount({
    required int accountId,
    String? description,
    String? internalNumber,
    bool? isAppAccount,
    bool? isDesktopAccount,
    @Default({}) Map<String, dynamic> sipRegInfo,
  }) = _SharedContactVoipAccount;

  factory SharedContactVoipAccount.fromJson(Map<String, dynamic> json) =>
      _$SharedContactVoipAccountFromJson(json);
}

@freezed
class SharedContactGroup with _$SharedContactGroup {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SharedContactGroup({
    String? name,
  }) = _SharedContactGroup;

  factory SharedContactGroup.fromJson(Map<String, dynamic> json) =>
      _$SharedContactGroupFromJson(json);
}