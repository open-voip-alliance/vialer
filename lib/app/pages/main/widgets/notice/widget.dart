import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../domain/user/permissions/permission.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/conditional_capitalization.dart';
import '../../../../util/widgets_binding_observer_registrar.dart';
import '../../../../widgets/animated_visibility.dart';
import '../../business_availability/temporary_redirect/explanation.dart';
import '../../business_availability/temporary_redirect/page.dart';
import 'cubit.dart';
import 'widgets/banner.dart';

class Notice extends StatelessWidget {
  final Widget child;

  const Notice({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NoticeCubit>(
      lazy: false,
      create: (_) => NoticeCubit(context.read()),
      child: _Notice(child),
    );
  }
}

/// Private widget with a context that has access to [NoticeCubit].
class _Notice extends StatefulWidget {
  final Widget child;

  _Notice(this.child);

  @override
  _NoticeState createState() => _NoticeState();
}

class _NoticeState extends State<_Notice>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      context.read<NoticeCubit>().check();
    }
  }

  IconData _iconFor(NoticeState state) {
    if (state is PhonePermissionDeniedNotice) {
      return FontAwesomeIcons.phoneXmark;
    } else if (state is MicrophonePermissionDeniedNotice) {
      return FontAwesomeIcons.microphoneSlash;
    } else if (state is BluetoothConnectPermissionDeniedNotice) {
      return FontAwesomeIcons.bluetooth;
    } else if (state is NotificationsPermissionDeniedNotice) {
      return FontAwesomeIcons.eyeSlash;
    } else if (state is TemporaryRedirectNotice) {
      return FontAwesomeIcons.listTree;
    } else {
      return FontAwesomeIcons.exclamation;
    }
  }

  String _titleFor(NoticeState state) {
    if (state is PhonePermissionDeniedNotice) {
      return context.msg.main.notice.phone.title;
    } else if (state is MicrophonePermissionDeniedNotice) {
      return context.msg.main.notice.microphone.title;
    } else if (state is BluetoothConnectPermissionDeniedNotice) {
      return context.msg.main.notice.bluetoothConnect.title;
    } else if (state is NotificationsPermissionDeniedNotice) {
      return context.msg.main.notice.notifications.title;
    } else if (state is TemporaryRedirectNotice) {
      return context.msg.main.temporaryRedirect.title;
    } else {
      return context.msg.main.notice.phoneAndMicrophone.title;
    }
  }

  Widget _contentFor(NoticeState state) {
    if (state is TemporaryRedirectNotice) {
      return TemporaryRedirectExplanation(
        currentDestination: state.temporaryRedirect.destination,
      );
    }

    final String content;
    if (state is PhonePermissionDeniedNotice) {
      content = context.msg.main.notice.phone.content(context.brand.appName);
    } else if (state is MicrophonePermissionDeniedNotice) {
      content =
          context.msg.main.notice.microphone.content(context.brand.appName);
    } else if (state is BluetoothConnectPermissionDeniedNotice) {
      content = context.msg.main.notice.bluetoothConnect
          .content(context.brand.appName);
    } else if (state is NotificationsPermissionDeniedNotice) {
      content = context.msg.main.notice.notifications.content;
    } else {
      content = context.msg.main.notice.phoneAndMicrophone.content(
        context.brand.appName,
      );
    }

    return Text(content);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<NoticeCubit, NoticeState>(
          builder: (context, state) {
            final cubit = context.read<NoticeCubit>();

            return AnimatedVisibility(
              visible: state is! NoNotice,
              child: NoticeBanner(
                icon: FaIcon(_iconFor(state)),
                title: Text(_titleFor(state)),
                content: _contentFor(state),
                actions: [
                  if (state is TemporaryRedirectNotice) ...[
                    if (state.canChangeTemporaryRedirect) ...[
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          TemporaryRedirectPickerPage.route(),
                        ),
                        child: Text(
                          context.msg.main.temporaryRedirect.actions
                              .changeRedirect.label
                              .toUpperCaseIfAndroid(context),
                        ),
                      ),
                    ],
                  ] else ...[
                    TextButton(
                      onPressed: cubit.dismiss,
                      child: Text(
                        context.msg.generic.button.close
                            .toUpperCaseIfAndroid(context),
                      ),
                    ),
                    TextButton(
                      onPressed: () => cubit.requestPermission(
                        [
                          if (state is PhonePermissionDeniedNotice)
                            Permission.phone
                          else if (state is MicrophonePermissionDeniedNotice)
                            Permission.microphone
                          else if (state
                              is BluetoothConnectPermissionDeniedNotice)
                            Permission.bluetooth
                          else if (state is NotificationsPermissionDeniedNotice)
                            Permission.notifications
                          else ...[Permission.phone, Permission.microphone],
                        ],
                      ),
                      child: Text(
                        context.msg.main.notice.actions.givePermission
                            .toUpperCaseIfAndroid(context),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        Expanded(
          child: widget.child,
        ),
      ],
    );
  }
}
