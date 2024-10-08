import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/data/models/user/user.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../../data/repositories/voipgrid/user_permissions.dart';
import '../../../../data/models/event/event_bus.dart';
import '../../../../data/models/user/settings/app_setting.dart';
import '../../../../data/models/user/settings/setting_changed.dart';
import '../../../../dependency_locator.dart';
import '../../../../domain/usecases/user/get_logged_in_user.dart';
import '../../shared/controllers/caller/cubit.dart';
import '../../shared/widgets/bottom_toggle.dart';
import '../../util/stylized_snack_bar.dart';
import '../call/widgets/outgoing_number_prompt/show_prompt.dart';
import 'controllers/cubit.dart';
import 'widgets/list.dart';

class RecentCallsPage extends StatefulWidget {
  const RecentCallsPage({
    super.key,
    this.listPadding = EdgeInsets.zero,
    this.snackBarPadding = EdgeInsets.zero,
  });

  /// Note that `top` will always be overridden to `8`.
  final EdgeInsets listPadding;
  final EdgeInsets snackBarPadding;

  @override
  State<RecentCallsPage> createState() => _RecentCallsPageState();
}

class _RecentCallsPageState extends State<RecentCallsPage> {
  final _eventBus = dependencyLocator<EventBusObserver>();
  StreamSubscription<SettingChangedEvent<Object>>? _eventBusSubscription;

  final _getUser = GetLoggedInUserUseCase();

  bool _showClientCalls = false;

  final _manualRefresher = ManualRefresher();
  final _clientManualRefresher = ManualRefresher();

  @override
  void initState() {
    super.initState();

    unawaited(_updateShowClientCalls());

    _eventBusSubscription = _eventBus.onSettingChange<bool>(
      AppSetting.showClientCalls,
      (oldValue, newValue) {
        unawaited(_updateShowClientCalls(settingValue: newValue));
      },
    );
  }

  Future<void> _updateShowClientCalls({bool? settingValue}) async {
    final user = _getUser();

    final enabled =
        settingValue ?? user.settings.get(AppSetting.showClientCalls);
    final hasPermission = user.hasPermission(Permission.canSeeClientCalls);

    setState(() {
      _showClientCalls = enabled && hasPermission;
    });
  }

  void _refreshListWithDelay() {
    //Add a small delay to allow the call to be added to the list.
    Future.delayed(Duration(seconds: 1), () {
      _manualRefresher.refresh();
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

    if (state is FinishedCalling) {
      _refreshListWithDelay();
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
    unawaited(_eventBusSubscription?.cancel());

    super.dispose();
  }
}

class _Content extends StatefulWidget {
  const _Content({
    required this.showClientCalls,
    required this.listPadding,
    required this.snackBarPadding,
    required this.manualRefresher,
    required this.clientManualRefresher,
  });

  final bool showClientCalls;
  final EdgeInsets listPadding;
  final EdgeInsets snackBarPadding;
  final ManualRefresher manualRefresher;
  final ManualRefresher clientManualRefresher;

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
      length: 2,
      vsync: this,
    );

    tabController.addListener(
      () {
        if (!tabController.indexIsChanging) {
          if (tabController.index == 0) {
            unawaited(widget.manualRefresher.refresh());
          } else if (tabController.index == 1) {
            unawaited(widget.clientManualRefresher.refresh());
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
  const _Calls({
    required this.listPadding,
    required this.snackBarPadding,
    required this.manualRefresher,
  });

  final EdgeInsets listPadding;
  final EdgeInsets snackBarPadding;
  final ManualRefresher manualRefresher;

  Future<void> _refreshCalls(BuildContext context) async {
    final cubit = context.read<C>();
    await cubit.refreshRecentCalls();
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
          onRefresh: () async => _refreshCalls(context),
          onCallPressed: (number) => showOutgoingNumberPrompt(
            context,
            number,
            (_) => cubit.call(number),
          ),
          onCopyPressed: cubit.copyNumber,
          loadMoreCalls: cubit.loadMoreRecentCalls,
          manualRefresher: manualRefresher,
        );
      },
    );
  }
}

class _MissedCallsToggle extends StatelessWidget {
  const _MissedCallsToggle({
    required this.showClientCalls,
    required this.manualRefresher,
    required this.clientManualRefresher,
  });

  final bool showClientCalls;
  final ManualRefresher manualRefresher;
  final ManualRefresher clientManualRefresher;

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

      unawaited(clientManualRefresher.refresh());
    }

    unawaited(manualRefresher.refresh());
  }
}
