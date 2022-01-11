import 'package:equatable/equatable.dart';

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
