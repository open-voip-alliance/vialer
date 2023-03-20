import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../dependency_locator.dart';
import '../../../../domain/event/event_bus.dart';
import '../../../../domain/user/get_logged_in_user.dart';
import '../../../../domain/user/settings/app_setting.dart';
import '../../../../domain/user/settings/setting_changed.dart';
import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';
import '../util/stylized_snack_bar.dart';
import '../widgets/bottom_toggle.dart';
import '../widgets/caller/cubit.dart';
import '../widgets/header.dart';
import 'cubit.dart';
import 'widgets/list.dart';

class RecentCallsPage extends StatefulWidget {
  /// Note that `top` will always be overridden to `8`.
  final EdgeInsets listPadding;
  final EdgeInsets snackBarPadding;

  const RecentCallsPage({
    Key? key,
    this.listPadding = EdgeInsets.zero,
    this.snackBarPadding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  State<RecentCallsPage> createState() => _RecentCallsPageState();
}

class _RecentCallsPageState extends State<RecentCallsPage> {
  final _eventBus = dependencyLocator<EventBusObserver>();
  StreamSubscription? _eventBusSubscription;

  final _getLatestUser = GetLoggedInUserUseCase();

  bool _showClientCalls = false;

  final _manualRefresher = ManualRefresher();
  final _clientManualRefresher = ManualRefresher();

  @override
  void initState() {
    super.initState();

    _updateShowClientCalls();

    _eventBusSubscription = _eventBus.onSettingChange<bool>(
      AppSetting.showClientCalls,
      (oldValue, newValue) {
        _updateShowClientCalls(settingValue: newValue);
      },
    );
  }

  Future<void> _updateShowClientCalls({bool? settingValue}) async {
    final user = await _getLatestUser();

    final enabled =
        settingValue ?? user.settings.get(AppSetting.showClientCalls);
    final hasPermission = user.permissions.canSeeClientCalls;

    setState(() {
      _showClientCalls = enabled && hasPermission;
    });
  }

  void _onStateChanged(BuildContext context, CallerState state) {
    if (state is NoPermission) {
      showSnackBar(
        context,
        icon: const FaIcon(FontAwesomeIcons.exclamation),
        label: Text(context.msg.main.contacts.snackBar.noPermission),
        padding: const EdgeInsets.only(right: 72),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallerCubit, CallerState>(
      listener: _onStateChanged,
      child: _Content(
        showClientCalls: _showClientCalls,
        listPadding: widget.listPadding,
        snackBarPadding: widget.snackBarPadding,
        manualRefresher: _manualRefresher,
        clientManualRefresher: _clientManualRefresher,
      ),
    );
  }

  @override
  void dispose() {
    _eventBusSubscription?.cancel();

    super.dispose();
  }
}

class _Content extends StatefulWidget {
  final bool showClientCalls;
  final EdgeInsets listPadding;
  final EdgeInsets snackBarPadding;
  final ManualRefresher manualRefresher;
  final ManualRefresher clientManualRefresher;

  const _Content({
    required this.showClientCalls,
    required this.listPadding,
    required this.snackBarPadding,
    required this.manualRefresher,
    required this.clientManualRefresher,
  });

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> with TickerProviderStateMixin {
  TabController? tabController;

  @override
  void initState() {
    super.initState();

    if (widget.showClientCalls) {
      _createTabController();
    }
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_Content oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showClientCalls && !oldWidget.showClientCalls) {
      _createTabController();
      return;
    }

    if (!widget.showClientCalls) {
      tabController?.dispose();
      tabController = null;
      return;
    }
  }

  void _createTabController() {
    final tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );

    tabController.addListener(
      () {
        if (!tabController.indexIsChanging) {
          if (tabController.index == 0) {
            widget.manualRefresher.refresh();
          } else if (tabController.index == 1) {
            widget.clientManualRefresher.refresh();
          }
        }
      },
    );

    this.tabController = tabController;
  }

  @override
  Widget build(BuildContext context) {
    final personalCalls = _Calls<RecentCallsCubit>(
      listPadding: widget.listPadding,
      snackBarPadding: widget.snackBarPadding,
      manualRefresher: widget.manualRefresher,
    );

    final content = BlocProvider<RecentCallsCubit>(
      create: (context) => RecentCallsCubit(context.read<CallerCubit>()),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              if (widget.showClientCalls)
                TabBar(
                  controller: tabController,
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
                    Text(
                      context.msg.main.recent.tabs.personal.toUpperCase(),
                    ),
                    Text(context.msg.main.recent.tabs.all.toUpperCase()),
                  ],
                ),
              Expanded(
                child: widget.showClientCalls
                    ? TabBarView(
                        controller: tabController,
                        children: [
                          personalCalls,
                          _Calls<ClientCallsCubit>(
                            listPadding: widget.listPadding,
                            snackBarPadding: widget.snackBarPadding,
                            manualRefresher: widget.clientManualRefresher,
                          ),
                        ],
                      )
                    : personalCalls,
              ),
              _MissedCallsToggle(
                showClientCalls: widget.showClientCalls,
                manualRefresher: widget.manualRefresher,
                clientManualRefresher: widget.clientManualRefresher,
              ),
            ],
          ),
        ),
      ),
    );

    return widget.showClientCalls
        ? BlocProvider<ClientCallsCubit>(
            create: (context) => ClientCallsCubit(context.read<CallerCubit>()),
            child: content,
          )
        : content;
  }
}

class _Calls<C extends RecentCallsCubit> extends StatelessWidget {
  final EdgeInsets listPadding;
  final EdgeInsets snackBarPadding;
  final ManualRefresher manualRefresher;

  const _Calls({
    super.key,
    required this.listPadding,
    required this.snackBarPadding,
    required this.manualRefresher,
  });

  Future<void> _refreshCalls(BuildContext context) async {
    await context.read<C>().performBackgroundImport();
    await context.read<C>().refreshRecentCalls();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C, RecentCallsState>(
      builder: (context, state) {
        final cubit = context.watch<C>();
        final recentCalls = state.callRecords;

        return RecentCallsList(
          listPadding: listPadding,
          snackBarPadding: snackBarPadding,
          isLoadingInitial: state is LoadingInitialRecentCalls,
          callRecords: recentCalls,
          onRefresh: () => _refreshCalls(context),
          onCallPressed: cubit.call,
          onCopyPressed: cubit.copyNumber,
          loadMoreCalls: cubit.loadMoreRecentCalls,
          performBackgroundImport: cubit.performBackgroundImport,
          manualRefresher: manualRefresher,
        );
      },
    );
  }
}

class _MissedCallsToggle extends StatelessWidget {
  final bool showClientCalls;
  final ManualRefresher manualRefresher;
  final ManualRefresher clientManualRefresher;

  const _MissedCallsToggle({
    required this.showClientCalls,
    required this.manualRefresher,
    required this.clientManualRefresher,
  });

  @override
  Widget build(BuildContext context) {
    return BottomToggle(
      name: context.msg.main.recent.onlyShowMissedCalls,
      initialValue: false,
      onChanged: (value) => _onChanged(context, value),
    );
  }

  void _onChanged(BuildContext context, bool value) {
    context.read<RecentCallsCubit>().onlyMissedCalls = value;

    if (showClientCalls) {
      context.read<ClientCallsCubit>().onlyMissedCalls = value;

      clientManualRefresher.refresh();
    }

    manualRefresher.refresh();
  }
}
