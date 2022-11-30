import 'package:freezed_annotation/freezed_annotation.dart';

import '../voicemail/voicemail_account.dart';

part 'temporary_redirect.freezed.dart';

@freezed
class TemporaryRedirect with _$TemporaryRedirect {
  const factory TemporaryRedirect({
    String? id,
    required DateTime endsAt,
    required TemporaryRedirectDestination destination,
  }) = _TemporaryRedirect;
}

@freezed
class TemporaryRedirectDestination with _$TemporaryRedirectDestination {
  const factory TemporaryRedirectDestination.voicemail(
    VoicemailAccount voicemailAccount,
  ) = Voicemail;
}