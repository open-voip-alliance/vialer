import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/call_record_with_contact.dart';
import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';
import '../../../util/widgets_binding_observer_registrar.dart';
import '../util/stylized_snack_bar.dart';
import '../widgets/caller/cubit.dart';
import '../widgets/conditional_placeholder.dart';
import '../widgets/header.dart';
import 'cubit.dart';
import 'widgets/item.dart';

class RecentCallsPage extends StatelessWidget {
  final double listBottomPadding;
  final double snackBarRightPadding;

  RecentCallsPage({
    Key? key,
    this.listBottomPadding = 0,
    this.snackBarRightPadding = 0,
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

  Future<void> _refreshCalls(BuildContext context) async {
    context.read<MissedCallsCubit>().refreshRecentCalls();
    context.read<RecentCallsCubit>().refreshRecentCalls();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: BlocListener<CallerCubit, CallerState>(
            listener: _onStateChanged,
            child: MultiBlocProvider(
              providers: [
                BlocProvider<RecentCallsCubit>(
                  create: (context) =>
                      RecentCallsCubit(context.read<CallerCubit>()),
                ),
                BlocProvider<MissedCallsCubit>(
                  create: (context) =>
                      MissedCallsCubit(context.read<CallerCubit>()),
                ),
              ],
              child: DefaultTabController(
                length: 2,
                child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    bottom: TabBar(
                      labelPadding: const EdgeInsets.only(
                        top: 18,
                        bottom: 8,
                      ),
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Theme.of(context).primaryColor,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: [
                        Text(context.msg.main.recent.tabs.all.toUpperCase()),
                        Text(context.msg.main.recent.tabs.missed.toUpperCase()),
                      ],
                    ),
                    title: Header(
                      context.msg.main.recent.title,
                      padding: const EdgeInsets.all(0),
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      BlocBuilder<RecentCallsCubit, RecentCallsState>(
                        builder: (context, recentCallState) {
                          final cubit = context.watch<RecentCallsCubit>();
                          final recentCalls = recentCallState.callRecords;
                          return _RecentCallsList(
                            listBottomPadding: listBottomPadding,
                            snackBarRightPadding: snackBarRightPadding,
                            isLoadingInitial:
                                recentCallState is LoadingInitialRecentCalls,
                            callRecords: recentCalls,
                            onRefresh: () => _refreshCalls(context),
                            onCallPressed: cubit.call,
                            onCopyPressed: cubit.copyNumber,
                            loadMoreCalls: cubit.loadMoreRecentCalls,
                          );
                        },
                      ),
                      BlocBuilder<MissedCallsCubit, RecentCallsState>(
                        builder: (context, missedCallsState) {
                          final missedCallsCubit =
                              context.watch<MissedCallsCubit>();
                          final missedCalls = missedCallsState.callRecords;
                          return _RecentCallsList(
                            listBottomPadding: listBottomPadding,
                            snackBarRightPadding: snackBarRightPadding,
                            isLoadingInitial:
                                missedCallsState is LoadingInitialRecentCalls,
                            callRecords: missedCalls,
                            onRefresh: () => _refreshCalls(context),
                            onCallPressed: missedCallsCubit.call,
                            onCopyPressed: missedCallsCubit.copyNumber,
                            loadMoreCalls: missedCallsCubit.loadMoreRecentCalls,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentCallsList extends StatefulWidget {
  final double listBottomPadding;
  final double snackBarRightPadding;

  final bool isLoadingInitial;

  final List<CallRecordWithContact> callRecords;
  final Future<void> Function() onRefresh;
  final void Function(String) onCallPressed;
  final void Function(String) onCopyPressed;
  final void Function() loadMoreCalls;

  const _RecentCallsList({
    Key? key,
    required this.listBottomPadding,
    required this.snackBarRightPadding,
    this.isLoadingInitial = false,
    required this.callRecords,
    required this.onRefresh,
    required this.onCallPressed,
    required this.onCopyPressed,
    required this.loadMoreCalls,
  }) : super(key: key);

  @override
  _RecentCallsListState createState() => _RecentCallsListState();
}

class _RecentCallsListState extends State<_RecentCallsList>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScrolling);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.onRefresh();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  void _handleScrolling() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 200) {
      widget.loadMoreCalls();
    }
  }

  void _showSnackBar(BuildContext context) {
    showSnackBar(
      context,
      icon: const Icon(VialerSans.copy),
      label: Text(context.msg.main.recent.snackBar.copied),
      padding: EdgeInsets.only(
        right: widget.snackBarRightPadding,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConditionalPlaceholder(
      showPlaceholder: widget.callRecords.isEmpty || widget.isLoadingInitial,
      placeholder: widget.isLoadingInitial
          ? LoadingIndicator(
              title: Text(
                context.msg.main.recent.list.loading.title,
              ),
              description: Text(
                context.msg.main.recent.list.loading.description,
              ),
            )
          : Warning(
              icon: const Icon(VialerSans.missedCall),
              title: Text(context.msg.main.recent.list.empty.title),
              description: Text(
                context.msg.main.recent.list.empty.description,
              ),
            ),
      child: RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          padding: EdgeInsets.only(
            bottom: widget.listBottomPadding,
          ),
          itemCount: widget.callRecords.length,
          itemBuilder: (context, index) {
            final callRecord = widget.callRecords[index];
            return RecentCallItem(
              callRecord: callRecord,
              onCallPressed: () {
                widget.onCallPressed(callRecord.thirdPartyNumber);
              },
              onCopyPressed: () {
                widget.onCopyPressed(callRecord.thirdPartyNumber);
                _showSnackBar(context);
              },
            );
          },
        ),
      ),
    );
  }
}
