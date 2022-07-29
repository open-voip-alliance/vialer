import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';
import '../../../widgets/stylized_button.dart';
import '../util/stylized_snack_bar.dart';
import '../widgets/caller/cubit.dart';
import '../widgets/header.dart';
import 'cubit.dart';
import 'widgets/list.dart';

class RecentCallsPage extends StatelessWidget {
  /// Note that `top` will always be overridden to `8`.
  final EdgeInsets listPadding;
  final EdgeInsets snackBarPadding;

  const RecentCallsPage({
    Key? key,
    this.listPadding = EdgeInsets.zero,
    this.snackBarPadding = EdgeInsets.zero,
  }) : super(key: key);

  void _onStateChanged(BuildContext context, CallerState state) {
    if (state is NoPermission) {
      showSnackBar(
        context,
        icon: const Icon(VialerSans.exclamationMark),
        label: Text(context.msg.main.contacts.snackBar.noPermission),
        padding: const EdgeInsets.only(right: 72),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallerCubit, CallerState>(
      listener: _onStateChanged,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<RecentCallsCubit>(
            create: (context) => RecentCallsCubit(context.read<CallerCubit>()),
          ),
          BlocProvider<MissedCallsCubit>(
            create: (context) => MissedCallsCubit(context.read<CallerCubit>()),
          ),
        ],
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              bottom: TabBar(
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                labelPadding: const EdgeInsets.only(
                  top: 18,
                  bottom: 8,
                ),
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: context.brand.theme.colors.grey1,
                indicatorColor: Theme.of(context).primaryColor,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: [
                  Text(context.msg.main.recent.tabs.all.toUpperCase()),
                  Text(
                    context.msg.main.recent.tabs.personal.toUpperCase(),
                  ),
                ],
              ),
              centerTitle: false,
              title: Header(
                context.msg.main.recent.title,
                padding: const EdgeInsets.only(top: 8),
              ),
            ),
            body: SafeArea(
              child: _Content(
                listPadding: listPadding,
                snackBarPadding: snackBarPadding,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final EdgeInsets listPadding;
  final EdgeInsets snackBarPadding;

  const _Content({
    required this.listPadding,
    required this.snackBarPadding,
  });

  Future<void> _refreshCalls(BuildContext context) async {
    context.read<RecentCallsCubit>().refreshRecentCalls();
    context.read<MissedCallsCubit>().refreshRecentCalls();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecentCallsCubit, RecentCallsState>(
      builder: (context, recentCallState) {
        final cubit = context.watch<RecentCallsCubit>();
        final recentCalls = recentCallState.callRecords;

        return BlocBuilder<MissedCallsCubit, RecentCallsState>(
          builder: (context, missedCallsState) {
            final missedCallsCubit = context.watch<MissedCallsCubit>();
            final missedCalls = missedCallsState.callRecords;

            return Column(
              children: [
                Expanded(
                  child: TabBarView(
                    children: [
                      RecentCallsList(
                        listPadding: listPadding,
                        snackBarPadding: snackBarPadding,
                        isLoadingInitial:
                            recentCallState is LoadingInitialRecentCalls,
                        callRecords: recentCalls,
                        onRefresh: () => _refreshCalls(context),
                        onCallPressed: cubit.call,
                        onCopyPressed: cubit.copyNumber,
                        loadMoreCalls: cubit.loadMoreRecentCalls,
                      ),
                      RecentCallsList(
                        listPadding: listPadding,
                        snackBarPadding: snackBarPadding,
                        isLoadingInitial:
                            missedCallsState is LoadingInitialRecentCalls,
                        callRecords: missedCalls,
                        onRefresh: () => _refreshCalls(context),
                        onCallPressed: missedCallsCubit.call,
                        onCopyPressed: missedCallsCubit.copyNumber,
                        loadMoreCalls: missedCallsCubit.loadMoreRecentCalls,
                      ),
                    ],
                  ),
                ),
                _Filters(
                  onPressed: () {},
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _Filters extends StatelessWidget {
  final VoidCallback onPressed;

  const _Filters({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: StylizedButton.outline(
        colored: true,
        margin: const EdgeInsets.all(8),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.tune),
            const SizedBox(width: 8),
            Text(context.msg.main.recent.filters),
          ],
        ),
      ),
    );
  }
}
