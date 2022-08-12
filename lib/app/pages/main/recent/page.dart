import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../dependency_locator.dart';
import '../../../../domain/entities/setting.dart';
import '../../../../domain/events/event_bus.dart';
import '../../../../domain/events/show_client_calls_setting_enabled.dart';
import '../../../../domain/usecases/get_latest_voipgrid_permissions.dart';
import '../../../../domain/usecases/get_setting.dart';
import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';
import '../../../widgets/stylized_button.dart';
import '../util/stylized_snack_bar.dart';
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

  final _getVoipgridPermissions = GetLatestVoipgridPermissions();
  final _getShowClientCallsSetting =
      GetSettingUseCase<ShowClientCallsSetting>();

  bool _showClientCalls = false;

  /// If true, means that the user enabled [ShowClientCallsSetting] in this
  /// session.
  ///
  /// **NOTE:** This only represents the setting and whether it was enabled
  /// this session. This should not be used to check whether the user should
  /// see client calls.
  bool _showClientCallsSettingEnabledThisSession = false;

  @override
  void initState() {
    super.initState();

    _getShowClientCallsSetting().then((setting) async {
      _updateShowClientCalls(settingValue: setting.value);
    });

    _eventBus.on<ShowClientCallsSettingChanged>((e) {
      _showClientCallsSettingEnabledThisSession = e.value;
      _updateShowClientCalls(settingValue: e.value);
    });
  }

  Future<void> _updateShowClientCalls({required bool settingValue}) async {
    final hasPermission =
        await _getVoipgridPermissions().then((p) => p.hasClientCallsPermission);

    setState(() {
      _showClientCalls = settingValue && hasPermission;
    });
  }

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
      child: _Content(
        showClientCalls: _showClientCalls,
        showClientCallsSettingEnabledThisSession:
            _showClientCallsSettingEnabledThisSession,
        listPadding: widget.listPadding,
        snackBarPadding: widget.snackBarPadding,
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final bool showClientCalls;
  final bool showClientCallsSettingEnabledThisSession;
  final EdgeInsets listPadding;
  final EdgeInsets snackBarPadding;

  const _Content({
    required this.showClientCalls,
    required this.showClientCallsSettingEnabledThisSession,
    required this.listPadding,
    required this.snackBarPadding,
  });

  @override
  Widget build(BuildContext context) {
    final personalCalls = _Calls<RecentCallsCubit>(
      listPadding: listPadding,
      snackBarPadding: snackBarPadding,
    );

    final content = BlocProvider<RecentCallsCubit>(
      create: (context) => RecentCallsCubit(context.read<CallerCubit>()),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: showClientCalls
              ? TabBar(
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
                )
              : null,
          centerTitle: false,
          title: Header(
            context.msg.main.recent.title,
            padding: const EdgeInsets.only(top: 8),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: showClientCalls
                    ? TabBarView(
                        children: [
                          _Calls<ClientCallsCubit>(
                            listPadding: listPadding,
                            snackBarPadding: snackBarPadding,
                          ),
                          personalCalls,
                        ],
                      )
                    : personalCalls,
              ),
              _Filters(
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );

    if (showClientCalls) {
      return BlocProvider<ClientCallsCubit>(
        create: (context) => ClientCallsCubit(
          context.read<CallerCubit>(),
          firstRun: showClientCallsSettingEnabledThisSession,
        ),
        child: DefaultTabController(
          length: 2,
          child: content,
        ),
      );
    } else {
      return content;
    }
  }
}

class _Calls<C extends RecentCallsCubit> extends StatelessWidget {
  final EdgeInsets listPadding;
  final EdgeInsets snackBarPadding;

  const _Calls({
    super.key,
    required this.listPadding,
    required this.snackBarPadding,
  });

  Future<void> _refreshCalls(BuildContext context) async {
    context.read<C>().refreshRecentCalls();
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
