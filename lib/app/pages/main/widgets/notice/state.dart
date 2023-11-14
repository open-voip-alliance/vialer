import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../domain/business_availability/temporary_redirect/temporary_redirect.dart';

part 'state.freezed.dart';

@freezed
sealed class NoticeState with _$NoticeState {
  const NoticeState._();

  const factory NoticeState.NoNotice() = NoNotice;
  const factory NoticeState.noticeDismissed() = NoticeDismissed;
  const factory NoticeState.microphonePermissionDeniedNotice() =
      MicrophonePermissionDeniedNotice;
  const factory NoticeState.phonePermissionDeniedNotice() =
      PhonePermissionDeniedNotice;
  const factory NoticeState.phoneAndMicrophonePermissionDeniedNotice() =
      PhoneAndMicrophonePermissionDeniedNotice;
  const factory NoticeState.bluetoothConnectPermissionDeniedNotice() =
      BluetoothConnectPermissionDeniedNotice;
  const factory NoticeState.notificationsPermissionDeniedNotice() =
      NotificationsPermissionDeniedNotice;
  const factory NoticeState.temporaryRedirectNotice({
    required TemporaryRedirect temporaryRedirect,
    required bool canChangeTemporaryRedirect,
  }) = TemporaryRedirectNotice;
  const factory NoticeState.noAppAccountNotice() = NoAppAccountNotice;
  const factory NoticeState.noGooglePlayServices() = NoGooglePlayServices;

  bool get isPermissionNotice => switch (this) {
        MicrophonePermissionDeniedNotice() ||
        PhonePermissionDeniedNotice() ||
        PhonePermissionDeniedNotice() ||
        PhoneAndMicrophonePermissionDeniedNotice() ||
        BluetoothConnectPermissionDeniedNotice() ||
        NotificationsPermissionDeniedNotice() =>
          true,
        _ => false,
      };
}
