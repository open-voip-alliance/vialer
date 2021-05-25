import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/brand.dart';
import '../../../../util/conditional_capitalization.dart';
import '../../../../util/widgets_binding_observer_registrar.dart';
import '../../../../widgets/animated_visibility.dart';
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
      create: (_) => NoticeCubit(),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<NoticeCubit, NoticeState>(
          builder: (context, state) {
            final cubit = context.read<NoticeCubit>();

            return AnimatedVisibility(
              visible: state is MicrophonePermissionDeniedNotice,
              child: NoticeBanner(
                icon: const Icon(VialerSans.mute),
                title: Text(context.msg.main.notice.microphone.title),
                content: Text(
                  context.msg.main.notice.microphone
                      .content(context.brand.appName),
                ),
                actions: [
                  TextButton(
                    onPressed: cubit.dismiss,
                    child: Text(
                      context.msg.generic.button.close
                          .toUpperCaseIfAndroid(context),
                    ),
                  ),
                  TextButton(
                    onPressed: cubit.requestMicrophonePermission,
                    child: Text(
                      context.msg.main.notice.microphone.actions.givePermissioon
                          .toUpperCaseIfAndroid(context),
                    ),
                  ),
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
