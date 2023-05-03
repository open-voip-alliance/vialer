import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../voicemail/voicemail_account.dart';

part 'temporary_redirect.freezed.dart';
part 'temporary_redirect.g.dart';

@freezed
class TemporaryRedirect with _$TemporaryRedirect {
  const factory TemporaryRedirect({
    required DateTime endsAt,
    required TemporaryRedirectDestination destination,
    String? id,
  }) = _TemporaryRedirect;

  factory TemporaryRedirect.fromJson(Map<String, dynamic> json) =>
      _$TemporaryRedirectFromJson(json);
}

@freezed
class TemporaryRedirectDestination with _$TemporaryRedirectDestination {
  const factory TemporaryRedirectDestination.voicemail(
    VoicemailAccount voicemailAccount,
  ) = Voicemail;

  const factory TemporaryRedirectDestination.unknown() = Unknown;

  factory TemporaryRedirectDestination.fromJson(Map<String, dynamic> json) =>
      _$TemporaryRedirectDestinationFromJson(json);
}

extension Display on TemporaryRedirectDestination {
  String get displayName => map(
        voicemail: (voicemail) {
          var name = voicemail.voicemailAccount.name;

          if (voicemail.voicemailAccount.description.isNotNullOrBlank) {
            name = '$name - ${voicemail.voicemailAccount.description}';
          }

          return name;
        },
        unknown: (unknown) => '',
      );
}
