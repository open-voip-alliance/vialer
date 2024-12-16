import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/resources/theme.dart';
import 'package:vialer/presentation/util/conditional_capitalization.dart';

import '../../../../../data/models/user/permissions/permission.dart';
import '../../../../../data/models/voipgrid/web_page.dart';
import '../../../features/business_availability/pages/temporary_redirect/page.dart';
import '../../../features/business_availability/widgets/temporary_redirect/explanation.dart';
import '../../../resources/localizations.dart';
import '../../../util/widgets_binding_observer_registrar.dart';
import '../../controllers/notice/cubit.dart';
import '../../pages/web_view.dart';
import 'banner.dart';

class Notice extends StatelessWidget {
  const Notice({
    required this.child,
    super.key,
  });

  final Widget child;

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
  const _Notice(this.child);

  final Widget child;

  @override
  _NoticeState createState() => _NoticeState();
}

class _NoticeState extends State<_Notice>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      unawaited(context.read<NoticeCubit>().check());
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
    } else if (state is NoAppAccountNotice) {
      return FontAwesomeIcons.userSlash;
    } else if (state is TemporaryRedirectNotice) {
      return FontAwesomeIcons.listTree;
    } else if (state is IgnoreBatteryOptimizationsPermissionDeniedNotice) {
      return FontAwesomeIcons.batteryFull;
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
    } else if (state is NoAppAccountNotice) {
      return context.msg.main.notice.noAppAccount.title;
    } else if (state is TemporaryRedirectNotice) {
      return context.msg.main.temporaryRedirect.title;
    } else if (state is NoGooglePlayServices) {
      return context.msg.main.notice.noGooglePlayServices.title;
    } else if (state is IgnoreBatteryOptimizationsPermissionDeniedNotice) {
      return context.msg.onboarding.permission.ignoreBatteryOptimizations.title;
    } else {
      return context.msg.main.notice.phoneAndMicrophone.title;
    }
  }

  Widget _contentFor(NoticeState state) {
    if (state is TemporaryRedirectNotice) {
      return TemporaryRedirectExplanation(
        currentDestination: state.temporaryRedirect.destination,
        endsAt: state.temporaryRedirect.endsAt,
      );
    }

    final app = context.brand.appName;
    final strings = context.msg.main.notice;

    final text = switch (state) {
      PhonePermissionDeniedNotice() => strings.phone.content(app),
      MicrophonePermissionDeniedNotice() => strings.microphone.content(app),
      BluetoothConnectPermissionDeniedNotice() =>
        strings.bluetoothConnect.content(app),
      NotificationsPermissionDeniedNotice() => strings.notifications.content,
      NoAppAccountNotice state => state.hasPermissionToChangeAppAccount
          ? strings.noAppAccount.content(app)
          : strings.noAppAccount.noPermission.content,
      NoGooglePlayServices() => strings.noGooglePlayServices.content,
      IgnoreBatteryOptimizationsPermissionDeniedNotice() => context.msg.main
          .settings.list.calling.ignoreBatteryOptimizations.description,
      _ => strings.phoneAndMicrophone.content(app),
    };

    return Text(text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<NoticeCubit, NoticeState>(
          builder: (context, state) {
            final cubit = context.read<NoticeCubit>();

            return Visibility(
              visible: state.shouldShow,
              child: NoticeBanner(
                icon: FaIcon(_iconFor(state)),
                title: Text(_titleFor(state)),
                content: _contentFor(state),
                actions: [
                  if (state is TemporaryRedirectNotice) ...[
                    if (state.canChangeTemporaryRedirect) ...[
                      TextButton(
                        onPressed: () => unawaited(
                          Navigator.push(
                            context,
                            TemporaryRedirectPickerPage.route(),
                          ),
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
                    if (state is NoAppAccountNotice &&
                        state.hasPermissionToChangeAppAccount) ...[
                      TextButton(
                        onPressed: () => unawaited(
                          WebViewPage.open(
                            context,
                            to: WebPage.telephonySettings,
                          ),
                        ),
                        child: Text(
                          context.msg.main.notice.actions.selectAccount
                              .toUpperCaseIfAndroid(context),
                        ),
                      ),
                    ] else if (state.isPermissionNotice) ...[
                      TextButton(
                        onPressed: () => unawaited(
                          cubit.requestPermission(
                            [
                              if (state is PhonePermissionDeniedNotice)
                                Permission.phone
                              else if (state
                                  is MicrophonePermissionDeniedNotice)
                                Permission.microphone
                              else if (state
                                  is BluetoothConnectPermissionDeniedNotice)
                                Permission.bluetooth
                              else if (state
                                  is NotificationsPermissionDeniedNotice)
                                Permission.notifications
                              else if (state
                                  is IgnoreBatteryOptimizationsPermissionDeniedNotice)
                                Permission.ignoreBatteryOptimizations
                              else ...[Permission.phone, Permission.microphone],
                            ],
                          ),
                        ),
                        child: Text(
                          context.msg.main.notice.actions.givePermission
                              .toUpperCaseIfAndroid(context),
                        ),
                      ),
                    ],
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
