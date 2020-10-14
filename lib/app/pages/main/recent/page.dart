import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/caller/cubit.dart';
import '../widgets/header.dart';
import '../widgets/conditional_placeholder.dart';
import 'widgets/item.dart';

import '../../../../domain/entities/call_with_contact.dart';
import '../../../resources/theme.dart';
import '../../../resources/localizations.dart';

import '../util/stylized_snack_bar.dart';

import 'cubit.dart';

class RecentCallsPage extends StatelessWidget {
  final double listBottomPadding;
  final double snackBarRightPadding;

  RecentCallsPage({
    Key key,
    this.listBottomPadding = 0,
    this.snackBarRightPadding = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: 16,
          ),
          child: BlocProvider<RecentCallsCubit>(
            create: (_) => RecentCallsCubit(context.bloc<CallerCubit>()),
            child: BlocBuilder<RecentCallsCubit, RecentCallsState>(
              builder: (context, state) {
                final cubit = context.bloc<RecentCallsCubit>();
                final recentCalls = state.calls;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Header(context.msg.main.recent.title),
                    ),
                    Expanded(
                      child: _RecentCallsList(
                        listBottomPadding: listBottomPadding,
                        snackBarRightPadding: snackBarRightPadding,
                        isLoadingInitial: state is LoadingInitialRecentCalls,
                        calls: recentCalls,
                        onRefresh: cubit.refreshRecentCalls,
                        onCallPressed: cubit.call,
                        onCopyPressed: cubit.copyNumber,
                      ),
                    ),
                  ],
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

  final List<CallWithContact> calls;
  final Future<void> Function() onRefresh;
  final void Function(String) onCallPressed;
  final void Function(String) onCopyPressed;

  const _RecentCallsList({
    Key key,
    this.listBottomPadding,
    this.snackBarRightPadding,
    this.isLoadingInitial = false,
    this.calls,
    this.onRefresh,
    this.onCallPressed,
    this.onCopyPressed,
  }) : super(key: key);

  @override
  _RecentCallsListState createState() => _RecentCallsListState();
}

class _RecentCallsListState extends State<_RecentCallsList>
    with
        // ignore: prefer_mixin
        WidgetsBindingObserver {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_handleScrolling);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.bloc<RecentCallsCubit>().refreshRecentCalls();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  void _handleScrolling() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    final cubit = context.bloc<RecentCallsCubit>();

    if (currentScroll >= maxScroll - 200) {
      cubit.loadMoreRecentCalls();
    }
  }

  void _showSnackBar(BuildContext context) {
    showSnackBar(
      context,
      icon: Icon(VialerSans.copy),
      label: Text(context.msg.main.recent.snackBar.copied),
      padding: EdgeInsets.only(
        right: widget.snackBarRightPadding,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConditionalPlaceholder(
      showPlaceholder: widget.calls.isEmpty || widget.isLoadingInitial,
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
              icon: Icon(VialerSans.missedCall),
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
          itemCount: widget.calls.length,
          itemBuilder: (context, index) {
            final call = widget.calls[index];
            return RecentCallItem(
              call: call,
              onCallPressed: () {
                widget.onCallPressed(call.destinationNumber);
              },
              onCopyPressed: () {
                widget.onCopyPressed(call.destinationNumber);
                _showSnackBar(context);
              },
            );
          },
        ),
      ),
    );
  }
}
