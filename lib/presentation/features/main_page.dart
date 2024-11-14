import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/features/relations/widgets/widget.dart';
import 'package:vialer/presentation/features/settings/controllers/cubit.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';
import 'package:vialer/presentation/shared/controllers/caller/cubit.dart';
import 'package:vialer/presentation/shared/controllers/user_availability_status_builder/cubit.dart';
import 'package:vialer/presentation/shared/widgets/bottom_navigation_profile_icon.dart';

import '../../../presentation/util/pigeon_extensions.dart';
import '../routes.dart';
import '../shared/widgets/app_update_checker/widget.dart';
import '../shared/widgets/connectivity_alert.dart';
import '../shared/widgets/nested_children.dart';
import '../shared/widgets/notice/widget.dart';
import '../shared/widgets/survey_triggerer/widget.dart';
import '../shared/widgets/transparent_status_bar.dart';
import '../shared/widgets/user_data_refresher/widget.dart';
import '../util/vialer_upgrade_alert.dart';
import 'call/widgets/call_button.dart';
import 'colltacts/controllers/colleagues/cubit.dart';
import 'colltacts/controllers/contacts/cubit.dart';
import 'colltacts/controllers/cubit.dart';
import 'colltacts/controllers/shared_contacts/cubit.dart';
import 'colltacts/pages/colltacts_page.dart';
import 'dialer/dialer_page.dart';
import 'recent/recent_calls_page.dart';
import 'settings/pages/settings.dart';

class MainPage extends ConsumerStatefulWidget {
  /// There can only be one.
  MainPage() : super(key: keys.page);

  @override
  MainPageState createState() => MainPageState();

  static final keys = _Keys();
}

class MainPageState extends ConsumerState<MainPage> {
  int? _currentIndex;

  List<Widget>? _pages;

  bool _dialerIsPage = false;

  final _navigatorKeys = [
    GlobalKey<NavigatorState>(),
  ];

  final _navigatorKey = GlobalKey<NavigatorState>();

  void navigateTo(MainPageTab tab) =>
      unawaited(_navigateTo(_dialerIsPage ? tab.index : tab.index - 1));

  Future<void> _navigateTo(int? index) async {
    if (index == null) return;

    _popProfileSubPages(index);

    setState(() {
      _currentIndex = index;

      if (context.isAndroid) {
        for (final key in _navigatorKeys) {
          key.currentState!.popUntil(ModalRoute.withName('/'));
        }
      }
    });
  }

  /// If we're on the profile page this will pop all of the subpages to get back
  /// to the main profile page.
  void _popProfileSubPages(int index) {
    if (!_isOnProfilePage) return;

    final navigator = Navigator.of(_navigatorKey.currentContext!);

    while (navigator.canPop()) navigator.pop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializePages();
  }

  @override
  void initState() {
    super.initState();
    NativeToFlutterSetup.onLaunchDialerAndPopulateNumber(
      (number) => Navigator.pushNamed(
        context,
        Routes.dialer,
        arguments: number,
      ),
    );
  }

  void _initializePages() {
    // Only on iOS is the dialer a separate bottom nav page.
    _dialerIsPage = context.isIOS;

    _pages = [
      if (_dialerIsPage) const DialerPage(isInBottomNavBar: true),
      ColltactsPage(
        navigatorKey: _navigatorKeys[0],
        bottomLettersPadding: !_dialerIsPage ? 96 : 0,
      ),
      RecentCallsPage(
        listPadding: !_dialerIsPage
            ? const EdgeInsets.only(bottom: 96)
            : EdgeInsets.zero,
        snackBarPadding:
            !_dialerIsPage ? const EdgeInsets.only(right: 72) : EdgeInsets.zero,
      ),
      SettingsPage(navigatorKey: _navigatorKey),
    ];

    _currentIndex ??= _dialerIsPage ? 1 : 0;
  }

  bool get _isOnProfilePage =>
      (_pages ?? [])[_currentIndex ?? 0] is SettingsPage;

  @override
  Widget build(BuildContext context) {
    return GentleUpdateReminder(
      child: MultiWidgetParent(
        [
          (child) => SurveyTriggerer(child: child),
          (child) => AppUpdateChecker.create(child: child),
          (child) => BlocProvider<SettingsCubit>(
                create: (_) => SettingsCubit(),
                child: child,
              ),
          (child) => MultiWidgetChildWithDependencies(
                builder: (context) {
                  return BlocProvider<UserAvailabilityStatusCubit>(
                    create: (_) => UserAvailabilityStatusCubit(
                      context.watch<SettingsCubit>(),
                    ),
                    child: child,
                  );
                },
              ),
          (child) => MultiWidgetChildWithDependencies(
                builder: (context) {
                  return BlocProvider<ColleaguesCubit>(
                    create: (_) =>
                        ColleaguesCubit(context.watch<CallerCubit>()),
                    child: child,
                  );
                },
              ),
          (child) => Builder(
                builder: (context) {
                  return BlocProvider<ColltactsTabsCubit>(
                    create: (_) => ColltactsTabsCubit(
                      context.watch<ContactsCubit>(),
                      context.watch<ColleaguesCubit>(),
                      context.watch<SharedContactsCubit>(),
                    ),
                    child: child,
                  );
                },
              ),
          (child) => BuildWebSocketDependantCubitsThenConnect(
                child: child,
              ),
        ],
        Scaffold(
          resizeToAvoidBottomInset: _isOnProfilePage,
          floatingActionButton: !_isOnProfilePage && !_dialerIsPage
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.decelerate,
                  padding: _currentIndex == 1
                      // TODO: Ideally this value should not be hardcoded. Now
                      // it's not responsive to e.g. font size changes.
                      ? const EdgeInsets.only(bottom: 64)
                      : EdgeInsets.zero,
                  child: SizedBox(
                    height: 62,
                    width: 62,
                    child: MergeSemantics(
                      child: Semantics(
                        label: context.msg.main.dialer.title,
                        child: FloatingActionButton(
                          // We use the CallButton's hero tag for a nice
                          // transition between the dialer and call button.
                          heroTag: CallButton.defaultHeroTag,
                          foregroundColor: Colors.white,
                          backgroundColor: context.brand.theme.colors.green1,
                          onPressed: () => unawaited(
                            Navigator.pushNamed(context, Routes.dialer),
                          ),
                          shape: CircleBorder(),
                          child: const Icon(
                            Icons.dialpad,
                            size: 31,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : null,
          bottomNavigationBar: _BottomNavigationBar(
            currentIndex: _currentIndex!,
            dialerIsPage: _dialerIsPage,
            onTap: _navigateTo,
          ),
          body: TransparentStatusBar(
            child: UserDataRefresher(
              child: ConnectivityAlert(
                child: SafeArea(
                  child: Notice(
                    child: _AnimatedIndexedStack(
                      index: _currentIndex!,
                      children: _pages!,
                    ),
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

class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    this.dialerIsPage = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool dialerIsPage;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: context.brand.theme.colors.grey2,
          ),
        ),
      ),
      child: NavigationBar(
        key: MainPage.keys.navigationBar,
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        destinations: [
          if (dialerIsPage)
            NavigationDestination(
              icon: const Icon(Icons.dialpad),
              label: context.msg.main.dialer.menu.title,
            ),
          NavigationDestination(
            icon: const FaIcon(FontAwesomeIcons.addressBook),
            selectedIcon: const FaIcon(FontAwesomeIcons.solidAddressBook),
            label: context.msg.main.contacts.menu.title,
          ),
          NavigationDestination(
            icon: const FaIcon(FontAwesomeIcons.clockRotateLeft),
            selectedIcon: const FaIcon(FontAwesomeIcons.solidClockRotateLeft),
            label: context.msg.main.recent.menu.title,
          ),
          NavigationDestination(
            icon: const BottomNavigationProfileIcon(active: false),
            selectedIcon: const BottomNavigationProfileIcon(active: true),
            label: context.msg.main.settings.menu.title,
          ),
        ],
      ),
    );
  }
}

enum MainPageTab {
  dialer,
  contacts,
  recents,
  settings,
}

class _AnimatedIndexedStack extends StatefulWidget {
  const _AnimatedIndexedStack({
    required this.index,
    this.children = const [],
  });

  final int index;
  final List<Widget> children;

  @override
  State<StatefulWidget> createState() => _AnimatedIndexedStackState();
}

class _AnimatedIndexedStackState extends State<_AnimatedIndexedStack>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  bool _animating = false;
  int? _previousIndex;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _controller
      ..addListener(() {
        if (_controller.status == AnimationStatus.completed ||
            _controller.status == AnimationStatus.dismissed) {
          setState(() {
            _animating = false;
          });
        }
      })
      ..value = 1;
  }

  @override
  void didUpdateWidget(_AnimatedIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.index != oldWidget.index) {
      _previousIndex = oldWidget.index;

      _controller
        ..reset()
        ..forward();
      _animating = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    var i = 0;
    for (final child in widget.children) {
      final shouldShow =
          i == widget.index || (_animating && i == _previousIndex);

      children.add(
        Offstage(
          offstage: !shouldShow,
          child: IgnorePointer(
            ignoring: !shouldShow,
            child: ScaleTransition(
              scale: _controller.drive(
                i == widget.index
                    ? Tween(begin: 0.9, end: 1)
                    : Tween(begin: 1, end: 0.9),
              ),
              child: FadeTransition(
                opacity: i == _previousIndex
                    ? _controller.drive(Tween(begin: 1, end: 0))
                    : _controller,
                child: child,
              ),
            ),
          ),
        ),
      );

      i++;
    }

    return Stack(
      fit: StackFit.expand,
      children: children,
    );
  }
}

class _Keys {
  final page = GlobalKey<MainPageState>();
  final navigationBar = GlobalKey<State<BottomNavigationBar>>();
}

/// Multiple cubits require the initial data that we receive when connecting
/// to the websocket so we want to ensure these cubits are created and
/// listening for events before we connect to the WebSocket.
class BuildWebSocketDependantCubitsThenConnect extends StatelessWidget {
  const BuildWebSocketDependantCubitsThenConnect({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiWidgetChildWithDependencies(
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<ColleaguesCubit>(context),
        child: BlocProvider.value(
          value: BlocProvider.of<UserAvailabilityStatusCubit>(context),
          child: ResgateManager.connect(child),
        ),
      ),
    );
  }
}
