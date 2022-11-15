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

class MicrophonePermissionDeniedNotice extends NoticeState {
  const MicrophonePermissionDeniedNotice();
}

class PhonePermissionDeniedNotice extends NoticeState {
  const PhonePermissionDeniedNotice();
}

class PhoneAndMicrophonePermissionDeniedNotice extends NoticeState {
  const PhoneAndMicrophonePermissionDeniedNotice();
}

class BluetoothConnectPermissionDeniedNotice extends NoticeState {
  const BluetoothConnectPermissionDeniedNotice();
}

class NotificationsPermissionDeniedNotice extends NoticeState {
  const NotificationsPermissionDeniedNotice();
}

class TemporaryRedirectNotice extends NoticeState {
  final TemporaryRedirect temporaryRedirect;

  const TemporaryRedirectNotice({required this.temporaryRedirect});

  @override
  List<Object> get props => [temporaryRedirect];
}
