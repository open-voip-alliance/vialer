import 'package:freezed_annotation/freezed_annotation.dart';

part 'voicemail_account.freezed.dart';
part 'voicemail_account.g.dart';

@freezed
class VoicemailAccount with _$VoicemailAccount {
  const VoicemailAccount._();

  const factory VoicemailAccount({
    @JsonKey(fromJson: _handleIntOrStringId) required String id,
    // Set to an empty string to support users on a version before this was
    // introduced. Eventually this can be removed and be made required.
    @Default('') String uuid,
    required String name,
    required String? description,
  }) = _VoicemailAccount;

  factory VoicemailAccount.fromJson(Map<String, dynamic> json) =>
      _$VoicemailAccountFromJson(json);
}

String _handleIntOrStringId(dynamic id) {
  if (id is String) return id;

  return (id as int).toString();
}
