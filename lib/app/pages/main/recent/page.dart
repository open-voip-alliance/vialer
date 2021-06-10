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

  void _showSnackBar(BuildContext context) {
    showSnackBar(
      context,
      icon: const Icon(VialerSans.exclamationMark),
      label: Text(context.msg.main.contacts.snackBar.noPermission),
      padding: const EdgeInsets.only(right: 72),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16,
          ),
          child: BlocProvider<RecentCallsCubit>(
            create: (context) => RecentCallsCubit(context.read<CallerCubit>()),
            child: BlocBuilder<RecentCallsCubit, RecentCallsState>(
              builder: (context, recentCallState) {
                final cubit = context.watch<RecentCallsCubit>();
                final recentCalls = recentCallState.callRecords;

                return BlocBuilder<CallerCubit, CallerState>(
                  builder: (context, callerState) {
                    void onCallPressed(String n) {
                      return (callerState is CanCall ||
                              (callerState is NoPermission &&
                                  !callerState.dontAskAgain))
                          ? cubit.call(n)
                          : _showSnackBar(context);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Header(context.msg.main.recent.title),
                        ),
                        Expanded(
                          child: _RecentCallsList(
                            listBottomPadding: listBottomPadding,
                            snackBarRightPadding: snackBarRightPadding,
                            isLoadingInitial:
                                recentCallState is LoadingInitialRecentCalls,
                            callRecords: recentCalls,
                            onRefresh: cubit.refreshRecentCalls,
                            onCallPressed: onCallPressed,
                            onCopyPressed: cubit.copyNumber,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
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

  const _RecentCallsList({
    Key? key,
    required this.listBottomPadding,
    required this.snackBarRightPadding,
    this.isLoadingInitial = false,
    required this.callRecords,
    required this.onRefresh,
    required this.onCallPressed,
    required this.onCopyPressed,
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
      context.read<RecentCallsCubit>().refreshRecentCalls();
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

    final cubit = context.read<RecentCallsCubit>();

    if (currentScroll >= maxScroll - 200) {
      cubit.loadMoreRecentCalls();
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
                widget.onCallPressed(callRecord.destinationNumber);
              },
              onCopyPressed: () {
                widget.onCopyPressed(callRecord.destinationNumber);
                _showSnackBar(context);
              },
            );
          },
        ),
      ),
    );
  }
}
