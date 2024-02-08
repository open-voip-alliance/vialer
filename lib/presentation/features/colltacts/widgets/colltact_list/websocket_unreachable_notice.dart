import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../resources/localizations.dart';
import '../../../../shared/widgets/animated_visibility.dart';
import '../../../../shared/widgets/notice/banner.dart';
import '../../controllers/colleagues/cubit.dart';

class WebSocketUnreachableNotice extends StatelessWidget {
  const WebSocketUnreachableNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: BlocBuilder<ColleaguesCubit, ColleaguesState>(
        builder: (_, state) {
          final colleaguesCubit = context.watch<ColleaguesCubit>();
          final showWebSocketUnreachableNotice =
              colleaguesCubit.shouldShowColleagues &&
                  state is ColleaguesLoaded &&
                  !state.upToDate;

          return AnimatedVisibility(
            visible: showWebSocketUnreachableNotice,
            child: NoticeBanner(
              icon: const FaIcon(FontAwesomeIcons.question),
              title: Text(
                context.msg.main.colleagues.websocketUnreachableNotice.title,
              ),
              content: Text(
                context.msg.main.colleagues.websocketUnreachableNotice
                    .content(context.brand.appName),
              ),
            ),
          );
        },
      ),
    );
  }
}
