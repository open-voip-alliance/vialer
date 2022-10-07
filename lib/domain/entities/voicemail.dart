import 'package:freezed_annotation/freezed_annotation.dart';

part 'voicemail.freezed.dart';
part 'voicemail.g.dart';

@freezed
class VoicemailAccount with _$VoicemailAccount {
  const factory VoicemailAccount({
    @JsonKey(fromJson: _intIdToString) required String id,
    required String name,
    required String description,
  }) = _VoicemailAccount;

  factory VoicemailAccount.fromJson(Map<String, dynamic> json) =>
      _$VoicemailAccountFromJson(json);
}

String _intIdToString(int id) => id.toString();
