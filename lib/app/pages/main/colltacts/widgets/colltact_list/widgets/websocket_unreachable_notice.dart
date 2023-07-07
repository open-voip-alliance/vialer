import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/app/pages/main/colltacts/colleagues/cubit.dart';

import '../../../../../../widgets/animated_visibility.dart';
import '../../../../widgets/notice/widgets/banner.dart';
import '../../../../../../resources/localizations.dart';
import '../../../../../../util/brand.dart';

class WebsocketUnreachableNotice extends StatelessWidget {
  const WebsocketUnreachableNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: BlocBuilder<ColleaguesCubit, ColleaguesState>(
        builder: (_, state) {
          final colleaguesCubit = context.watch<ColleaguesCubit>();
          final showWebsocketUnreachableNotice =
              colleaguesCubit.shouldShowColleagues &&
                  state is ColleaguesLoaded &&
                  !state.upToDate;

          return AnimatedVisibility(
            visible: showWebsocketUnreachableNotice,
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
