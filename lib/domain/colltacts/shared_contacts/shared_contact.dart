import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shared_contact.freezed.dart';
part 'shared_contact.g.dart';

@freezed
class SharedContact with _$SharedContact {
  const factory SharedContact({
    required String? id,
    required String? givenName,
    required String? familyName,
    required String? company,
    required List<SharedContactPhoneNumber> phoneNumbers,
    required List<SharedContactGroup> groups,
    required List<SharedContactVoipAccount> voipAccounts,
  }) = _SharedContact;

  factory SharedContact.fromJson(Map<String, dynamic> json) =>
      _$SharedContactFromJson(json);

  const SharedContact._();

  String get _fullName => [givenName, familyName].join(' ').trim();

  String get displayName {
    if (givenName.isNotNullOrBlank || familyName.isNotNullOrBlank) {
      return company.isNotNullOrBlank ? '$_fullName ($company)' : _fullName;
    } else if (company.isNotNullOrBlank) {
      return company!;
    }
    return '';
  }

  static List<SharedContact> listFromApiResponse(
      List<Map<String, dynamic>> response) {
    return [
      ...response.map((e) {
        final phoneNumbersList = e['phone_numbers'] as List<dynamic>;
        final phoneNumbers = [
          ...phoneNumbersList.map(
            (p) => SharedContactPhoneNumber(
              isValid: p['is_valid'] as bool,
              phoneNumberPretty: p['phone_number_pretty'] as String?,
              phoneNumberFlat: p['phone_number_flat'] as String?,
              phoneNumberType: p['phone_number_type'] as String?,
              callingCode: p['calling_code'] as String?,
              countryCode: p['country_code'] as String?,
              location: p['location'] as String?,
            ),
          ),
        ];

        final voipAccountsList = e['voip_accounts'] as List<dynamic>;
        final voipAccounts = [
          ...voipAccountsList.map(
            (p) => SharedContactVoipAccount(
              accountId: p['account_id'] as int,
              description: p['description'] as String?,
              internalNumber: p['internal_number'] as String?,
              isAppAccount: p['is_app_account'] as bool,
              isDesktopAccount: p['is_desktop_account'] as bool,
              sipRegInfo: p['sipreginfo'] as Map<String, dynamic>,
            ),
          ),
        ];

        final groupsList = e['groups'] as List<dynamic>;
        final groups = [
          ...groupsList.map(
            (p) => SharedContactGroup(
              name: p['name'] as String?,
            ),
          ),
        ];

        return SharedContact(
          id: e['id'] as String?,
          givenName: e['given_name'] as String?,
          familyName: e['family_name'] as String?,
          company: e['company_name'] as String?,
          phoneNumbers: phoneNumbers,
          groups: groups,
          voipAccounts: voipAccounts,
        );
      }),
    ];
  }
}

@freezed
class SharedContactPhoneNumber with _$SharedContactPhoneNumber {
  const factory SharedContactPhoneNumber({
    required bool isValid,
    required String? phoneNumberPretty,
    required String? phoneNumberFlat,
    required String? phoneNumberType,
    required String? callingCode,
    required String? countryCode,
    required String? location,
  }) = _SharedContactPhoneNumber;

  factory SharedContactPhoneNumber.fromJson(Map<String, dynamic> json) =>
      _$SharedContactPhoneNumberFromJson(json);

  const SharedContactPhoneNumber._();
}

@freezed
class SharedContactVoipAccount with _$SharedContactVoipAccount {
  const factory SharedContactVoipAccount({
    required int accountId,
    required String? description,
    required String? internalNumber,
    required bool isAppAccount,
    required bool isDesktopAccount,
    required Map<String, dynamic> sipRegInfo,
  }) = _SharedContactVoipAccount;

  factory SharedContactVoipAccount.fromJson(Map<String, dynamic> json) =>
      _$SharedContactVoipAccountFromJson(json);

  const SharedContactVoipAccount._();
}

@freezed
class SharedContactGroup with _$SharedContactGroup {
  const factory SharedContactGroup({
    required String? name,
  }) = _SharedContactGroup;

  factory SharedContactGroup.fromJson(Map<String, dynamic> json) =>
      _$SharedContactGroupFromJson(json);

  const SharedContactGroup._();
}
