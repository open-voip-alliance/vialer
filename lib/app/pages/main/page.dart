import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../resources/localizations.dart';
import '../../resources/theme.dart';
import '../../routes.dart';
import '../../util/conditional_capitalization.dart';
import '../../widgets/app_update_checker/widget.dart';
import '../../widgets/transparent_status_bar.dart';
import 'call/widgets/call_button.dart';
import 'contacts/page.dart';
import 'cubit.dart';
import 'dialer/page.dart';
import 'recent/page.dart';
import 'settings/page.dart';
import 'widgets/caller.dart';
import 'widgets/connectivity_alert.dart';
import 'widgets/notice/widget.dart';
import 'widgets/survey_triggerer/widget.dart';
import 'widgets/user_data_refresher/widget.dart';

class MainPage extends StatefulWidget {
  /// There can only be one.
  MainPage._() : super(key: keys.page);

  @override
  State<StatefulWidget> createState() => MainPageState();

  static Widget create() {
    return BlocProvider(
      create: (_) => MainCubit(),
      child: MainPage._(),
    );
  }

  static final keys = _Keys();
}

class MainPageState extends State<MainPage> {
  int? _currentIndex;
  int? _previousIndex;

  List<Widget>? _pages;

  bool _dialerIsPage = false;

  final _navigatorKeys = [
    GlobalKey<NavigatorState>(),
  ];

  void navigateTo(MainPageTab tab) =>
      _navigateTo(_dialerIsPage ? tab.index : tab.index - 1);

  void _navigateTo(int? index) {
    if (index == null) return;

    _previousIndex = _currentIndex;

    setState(() {
      _currentIndex = index;

      if (context.isAndroid) {
        for (final key in _navigatorKeys) {
          key.currentState!.popUntil(ModalRoute.withName('/'));
        }
      }
    });

    // Show a dialog when navigating to the Recents page for the first time.
    if ((_dialerIsPage && _currentIndex == 2) ||
        (!_dialerIsPage && _currentIndex == 1)) {
      final cubit = context.read<MainCubit>();

      if (cubit.shouldShowClientWideCallsDialog()) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(context.msg.main.recent.clientWideCallsDialog.title),
              content: Text(
                context.msg.main.recent.clientWideCallsDialog.description,
              ),
              actions: [
                TextButton(
                  onPressed: Navigator.of(context, rootNavigator: true).pop,
                  child: Text(
                    context.msg.generic.button.ok.toUpperCaseIfAndroid(context),
                  ),
                ),
              ],
            );
          },
        );

        cubit.markRecentCallsShown();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only on iOS is the dialer a separate bottom nav page.
    _dialerIsPage = context.isIOS;

    if (_pages == null) {
      _pages = [
        if (_dialerIsPage) const DialerPage(isInBottomNavBar: true),
        ContactsPage(
          navigatorKey: _navigatorKeys[0],
          bottomLettersPadding: !_dialerIsPage ? 96 : 0,
        ),
        RecentCallsPage(
          listPadding: !_dialerIsPage
              ? const EdgeInsets.only(bottom: 96)
              : EdgeInsets.zero,
          snackBarPadding: !_dialerIsPage
              ? const EdgeInsets.only(right: 72)
              : EdgeInsets.zero,
        ),
        const SettingsPage(),
      ];
    }

    if (_currentIndex == null) {
      _currentIndex = _dialerIsPage ? 1 : 0;
    }
  }

  void _onCallerStateChanged(BuildContext context, CallerState state) {
    if (context.isIOS &&
        state is FinishedCalling &&
        state.origin == CallOrigin.dialer) {
      _navigateTo(_previousIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SurveyTriggerer(
      child: AppUpdateChecker.create(
        child: BlocListener<CallerCubit, CallerState>(
          listener: _onCallerStateChanged,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            floatingActionButton: _currentIndex != 2 && !_dialerIsPage
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
                            backgroundColor: context.brand.theme.colors.green1,
                            onPressed: () =>
                                Navigator.pushNamed(context, Routes.dialer),
                            child: const Icon(VialerSans.dialpad, size: 31),
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
              brightness: Brightness.dark,
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
      ),
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool dialerIsPage;

  const _BottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.dialerIsPage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: context.brand.theme.colors.grey2,
          ),
        ),
      ),
      child: BottomNavigationBar(
        key: MainPage.keys.navigationBar,
        type: BottomNavigationBarType.fixed,
        iconSize: 24,
        selectedFontSize: 9,
        selectedItemColor: context.brand.theme.colors.primary,
        unselectedFontSize: 9,
        unselectedItemColor: context.brand.theme.colors.grey1,
        currentIndex: currentIndex,
        onTap: onTap,
        items: [
          if (dialerIsPage)
            BottomNavigationBarItem(
              icon: const _BottomNavigationBarIcon(VialerSans.dialpad),
              label: context.msg.main.dialer.menu.title,
            ),
          BottomNavigationBarItem(
            icon: const _BottomNavigationBarIcon(VialerSans.contacts),
            label: context.msg.main.contacts.menu.title,
          ),
          BottomNavigationBarItem(
            icon: const _BottomNavigationBarIcon(VialerSans.clock),
            label: context.msg.main.recent.menu.title,
          ),
          BottomNavigationBarItem(
            icon: const _BottomNavigationBarIcon(VialerSans.settings),
            label: context.msg.main.settings.menu.title,
          ),
        ],
      ),
    );
  }
}

class _BottomNavigationBarIcon extends StatelessWidget {
  final IconData icon;

  const _BottomNavigationBarIcon(this.icon, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Icon(icon),
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
  final int index;
  final List<Widget> children;

  const _AnimatedIndexedStack({
    Key? key,
    required this.index,
    this.children = const [],
  }) : super(key: key);

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

    _controller.addListener(() {
      if (_controller.status == AnimationStatus.completed ||
          _controller.status == AnimationStatus.dismissed) {
        setState(() {
          _animating = false;
        });
      }
    });

    _controller.value = 1;
  }

  @override
  void didUpdateWidget(_AnimatedIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.index != oldWidget.index) {
      _previousIndex = oldWidget.index;

      _controller.reset();
      _controller.forward();
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
                    ? Tween(begin: 0.9, end: 1.0)
                    : Tween(begin: 1.0, end: 0.9),
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
