import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vialer/app/pages/main/settings/sub_page/client/queue_statistics/queue_statistics.dart';
import 'package:vialer/app/widgets/stylized_dropdown.dart';

import '../../../cubit.dart';
import '../../widget.dart';
import '../../../../../../resources/theme.dart';

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
          loaded: (state) => _Loaded(state),
        );
      },
    );
  }
}

class _Loaded extends ConsumerWidget {
  const _Loaded(this.state);

  final Loaded state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueStatistics = ref.read(queueStatisticsProvider.notifier);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.max,
      children: [
        Visibility(
          visible: state.stats.keys.length <= 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: StylizedDropdown(
              value: state.selectedQueue,
              isExpanded: true,
              onChanged: (selected) =>
                  queueStatistics.selectSpecificQueue(selected!),
              items: state.stats.keys
                  .map(
                    (queueName) => DropdownMenuItem<String>(
                      child: Text(queueName),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                _QueueStatisticLarge(
                  title: 'Callers in the queue',
                  number: state.selectedStatistics.callersInQueue.toString(),
                  suffix: 'Waiting',
                ),
                _QueueStatisticLarge(
                  title: 'Active calls',
                  number: state.selectedStatistics.activeCalls.toString(),
                  suffix: 'Calls',
                ),
                _QueueStatisticLarge(
                  title: 'Online colleagues in call group',
                  number: state.selectedStatistics.loggedInAgents.toString(),
                  suffix: '/${state.selectedStatistics.totalAgents.toString()}',
                ),
                _QueueStatisticLarge(
                  title: 'Colleagues on a call or do not disturb',
                  number: state.selectedStatistics.dndAgents.toString(),
                  suffix:
                      '/${state.selectedStatistics.loggedInAgents.toString()}',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QueueStatisticLarge extends StatelessWidget {
  const _QueueStatisticLarge({
    required this.title,
    required this.number,
    required this.suffix,
  });

  final String title;
  final String number;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(title),
          Container(
            color: context.brand.theme.colors.grey7,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    number,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(suffix),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
