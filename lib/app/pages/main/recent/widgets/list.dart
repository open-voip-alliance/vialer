import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/entities/call_record.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/widgets_binding_observer_registrar.dart';
import '../../util/stylized_snack_bar.dart';
import '../../widgets/conditional_placeholder.dart';
import 'item.dart';

class RecentCallsList extends StatefulWidget {
  final EdgeInsets listPadding;
  final EdgeInsets snackBarPadding;

  final bool isLoadingInitial;

  final List<CallRecord> callRecords;
  final Future<void> Function() onRefresh;
  final void Function(String) onCallPressed;
  final void Function(String) onCopyPressed;
  final void Function() loadMoreCalls;
  final void Function() automaticallyPopulateCalls;
  final void Function() performBackgroundImport;

  final ManualRefresher manualRefresher;

  const RecentCallsList({
    Key? key,
    required this.listPadding,
    required this.snackBarPadding,
    this.isLoadingInitial = false,
    required this.callRecords,
    required this.onRefresh,
    required this.onCallPressed,
    required this.onCopyPressed,
    required this.loadMoreCalls,
    required this.manualRefresher,
    required this.automaticallyPopulateCalls,
    required this.performBackgroundImport,
  }) : super(key: key);

  @override
  _RecentCallsListState createState() => _RecentCallsListState();
}

class _RecentCallsListState extends State<RecentCallsList>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {
  final _scrollController = ScrollController();
  Timer? _localRefreshTimer;
  Timer? _backgroundImportTimer;

  static const _localRefreshInterval = Duration(seconds: 1);
  static const _backgroundImportInterval = Duration(seconds: 15);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScrolling);
    _localRefreshTimer = Timer.periodic(
        _localRefreshInterval, (_) => widget.automaticallyPopulateCalls());
    _backgroundImportTimer = Timer.periodic(
      _backgroundImportInterval,
      (_) => widget.performBackgroundImport(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      widget.manualRefresher.refresh();
      widget.performBackgroundImport();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _localRefreshTimer?.cancel();
    _localRefreshTimer = null;
    _backgroundImportTimer?.cancel();
    _backgroundImportTimer = null;
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
      padding: widget.snackBarPadding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: widget.manualRefresher._key,
      onRefresh: widget.onRefresh,
      color: context.brand.theme.colors.primary,
      child: ConditionalPlaceholder(
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
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Warning(
                  icon: const Icon(VialerSans.missedCall),
                  title: Text(context.msg.main.recent.list.empty.title),
                  description: Text(
                    context.msg.main.recent.list.empty.description,
                  ),
                ),
              ),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          padding: widget.listPadding.copyWith(top: 8),
          itemCount: widget.callRecords.length,
          itemBuilder: (context, index) {
            final callRecord = widget.callRecords[index];

            final item = RecentCallItem(
              callRecord: callRecord,
              onCallPressed: () {
                widget.onCallPressed(callRecord.thirdPartyNumber);
              },
              onCopyPressed: () {
                widget.onCopyPressed(callRecord.thirdPartyNumber);
                _showSnackBar(context);
              },
            );

            if (widget.callRecords.isHeaderRequiredAt(index)) {
              return RecentCallHeader(
                date: callRecord.date,
                isFirst: index == 0,
                child: item,
              );
            }

            return item;
          },
        ),
      ),
    );
  }
}

class ManualRefresher {
  final _key = GlobalKey<RefreshIndicatorState>();

  /// This will refresh the items in the list
  /// (calling [RecentCallList.onRefresh]), and also show the refresh indicator.
  Future<void>? refresh() => _key.currentState?.show();
}

extension on List<CallRecord> {
  bool isHeaderRequiredAt(int index) {
    final previous = index >= 1 ? this[index - 1] : null;

    return previous == null ||
        !previous.date.isAtSameDayAs(
          this[index].date,
        );
  }
}
