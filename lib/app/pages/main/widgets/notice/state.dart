import 'package:equatable/equatable.dart';

import '../../../../../domain/business_availability/temporary_redirect/temporary_redirect.dart';

abstract class NoticeState extends Equatable {
  const NoticeState();

  @override
  List<Object> get props => [];
}

class NoNotice extends NoticeState {
  const NoNotice();
}

class NoticeDismissed extends NoNotice {
  const NoticeDismissed();
}

abstract class PermissionNoticeState extends NoticeState {
  const PermissionNoticeState();
}

class MicrophonePermissionDeniedNotice extends PermissionNoticeState {
  const MicrophonePermissionDeniedNotice();
}

class PhonePermissionDeniedNotice extends PermissionNoticeState {
  const PhonePermissionDeniedNotice();
}

class PhoneAndMicrophonePermissionDeniedNotice extends PermissionNoticeState {
  const PhoneAndMicrophonePermissionDeniedNotice();
}

class BluetoothConnectPermissionDeniedNotice extends PermissionNoticeState {
  const BluetoothConnectPermissionDeniedNotice();
}

class NotificationsPermissionDeniedNotice extends PermissionNoticeState {
  const NotificationsPermissionDeniedNotice();
}

class TemporaryRedirectNotice extends NoticeState {
  const TemporaryRedirectNotice({
    required this.temporaryRedirect,
    required this.canChangeTemporaryRedirect,
  });

  final TemporaryRedirect temporaryRedirect;
  final bool canChangeTemporaryRedirect;

  @override
  List<Object> get props => [
        temporaryRedirect,
        canChangeTemporaryRedirect,
      ];
}

class NoAppAccountNotice extends NoticeState {
  const NoAppAccountNotice();
}

class NoGooglePlayServices extends NoticeState {
  const NoGooglePlayServices();
}
