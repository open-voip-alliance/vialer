import 'package:freezed_annotation/freezed_annotation.dart';

part 'voicemail_account.freezed.dart';
part 'voicemail_account.g.dart';

@freezed
class VoicemailAccount with _$VoicemailAccount {
  const factory VoicemailAccount({
    @JsonKey(fromJson: _handleIntOrStringId) required String id,
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
