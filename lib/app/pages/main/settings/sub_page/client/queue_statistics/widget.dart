import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vialer/app/pages/main/settings/sub_page/client/queue_statistics/queue_statistics.dart';

import '../../../cubit.dart';
import '../../widget.dart';

class QueueStatisticsSubPage extends ConsumerWidget {
  const QueueStatisticsSubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(queueStatisticsProvider);

    return SettingsSubPage(
      cubit: context.watch<SettingsCubit>(),
      title: 'Queue Statistics',
      child: (_) {
        return state.map(
          loading: (_) => Text('Loading'),
          loaded: (loaded) => Text('loaded'),
        );
      },
    );
  }
}
