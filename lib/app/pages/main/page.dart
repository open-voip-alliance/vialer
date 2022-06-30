import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart' hide NavigationDestination;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/navigation_destination.dart';
import '../../../domain/entities/web_page.dart';
import '../../resources/localizations.dart';
import '../../resources/theme.dart';
import '../../routes.dart';
import '../../widgets/app_update_checker/widget.dart';
import '../../widgets/transparent_status_bar.dart';
import '../web_view/page.dart';
import 'call/widgets/call_button.dart';
import 'contacts/page.dart';
import 'cubit.dart';
import 'dialer/page.dart';
import 'navigation/drawer/cubit.dart';
import 'navigation/drawer/widget.dart';
import 'recent/page.dart';
import 'settings/cubit.dart';
import 'settings/feedback/page.dart';
import 'settings/page.dart';
import 'telephony/page.dart';
import 'widgets/caller.dart';
import 'widgets/connectivity_alert.dart';
import 'widgets/notice/widget.dart';
import 'widgets/user_data_refresher/cubit.dart';
import 'widgets/user_data_refresher/widget.dart';

typedef DestinationPageMap = Map<NavigationDestination, Widget>;

class MainPage extends StatefulWidget {
  const MainPage._(Key? key) : super(key: key);

  @override
  State<StatefulWidget> createState() => MainPageState();

  static Widget create({Key? key}) {
    return BlocProvider(
      create: (_) => MainCubit(),
      child: MainPage._(key),
    );
  }
}

class MainPageState extends State<MainPage> {
  NavigationDestination? _currentDestination;
  NavigationDestination? _previousDestination;

  /// All the destinations available to the user to select in the drawer menu.
  var _destinations = <DestinationPage>[];

  /// The destinations that show in the bottom navigation bar.
  var _selectedDestinations = <NavigationDestination>[];

  bool get isDialerInNavBar =>
      _selectedDestinations.contains(NavigationDestination.dialer);

  final _navigatorKeys = [
    GlobalKey<NavigatorState>(),
  ];

  final _drawerKey = GlobalKey<ScaffoldState>();

  void navigateTo(BuildContext context, NavigationDestination destination) {
    // If the dialer isn't in the bottom bar, then we want to open it as a
    // new route.
    if (!isDialerInNavBar && destination == NavigationDestination.dialer) {
      Navigator.pushNamed(context, Routes.dialer);
      return;
    }

    if (destination == NavigationDestination.feedback) {
      Navigator.pushNamed(context, Routes.feedback);
      return;
    }

    _previousDestination = _currentDestination;

    setState(() {
      _currentDestination = destination;
    });

    context.read<MainCubit>().broadcastNavigation(
          _previousDestination,
          destination,
        );
  }

  void _onSelectedNavigationChanged(
    BuildContext context,
    NavigationState state,
  ) {
    setState(() {
      _selectedDestinations = state.selected;

      // Use the first selected destination as the default page to load.
      if (_currentDestination == null) {
        _currentDestination = _selectedDestinations.first;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // If loading for the first time, we want to build all destination pages.
    if (_destinations.isEmpty) {
      _destinations = _buildAllDestinations();
    }
  }

  List<DestinationPage> _buildAllDestinations() => [
        DestinationPage(
          NavigationDestination.contacts,
          ContactsPage(navigatorKey: _navigatorKeys[0]),
        ),
        DestinationPage(
          NavigationDestination.recents,
          RecentCallsPage(),
        ),
        const DestinationPage(
          NavigationDestination.settings,
          SettingsPage(),
        ),
        DestinationPage(
          NavigationDestination.dialer,
          DialerPage(isInBottomNavBar: isDialerInNavBar),
        ),
        const DestinationPage(
          NavigationDestination.feedback,
          FeedbackPage(),
        ),
        const DestinationPage(
          NavigationDestination.telephony,
          TelephonyPage(),
        ),
        DestinationPage(
          NavigationDestination.dialPlan,
          WebViewPage(WebPage.dialPlan),
        ),
        DestinationPage(
          NavigationDestination.stats,
          WebViewPage(WebPage.stats),
        ),
        DestinationPage(
          NavigationDestination.calls,
          WebViewPage(WebPage.calls),
        ),
      ];

  void _onCallerStateChanged(BuildContext context, CallerState state) {
    if (context.isIOS &&
        state is FinishedCalling &&
        state.origin == CallOrigin.dialer) {
      navigateTo(context, _previousDestination!);
    }
  }

  bool _shouldDisplayFloatingActionButton() =>
      !isDialerInNavBar &&
      const [
        NavigationDestination.recents,
        NavigationDestination.contacts,
      ].contains(_currentDestination);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationCubit>(
          create: (context) => NavigationCubit(),
        ),
        BlocProvider<UserDataRefresherCubit>(
          create: (context) => UserDataRefresherCubit(),
        ),
        BlocProvider<SettingsCubit>(
          create: (context) => SettingsCubit(
            context.read<UserDataRefresherCubit>(),
          ),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<CallerCubit, CallerState>(
            listener: _onCallerStateChanged,
          ),
          BlocListener<NavigationCubit, NavigationState>(
            listener: _onSelectedNavigationChanged,
          ),
        ],
        child: AppUpdateChecker.create(
          child: Scaffold(
            key: _drawerKey,
            drawer: NavigationDrawer(
              onNavigate: (destination) => navigateTo(
                context,
                destination,
              ),
            ),
            resizeToAvoidBottomInset: false,
            floatingActionButton: _shouldDisplayFloatingActionButton()
                ? _DialerFloatingActionButton(
                    onPressed: () =>
                        navigateTo(context, NavigationDestination.dialer),
                  )
                : null,
            bottomNavigationBar: _selectedDestinations.length >= 1
                ? _BottomNavigationBar(
                    currentDestination: _currentDestination,
                    destinations: _selectedDestinations,
                    onTap: (destination) => navigateTo(context, destination),
                    onMenuOpen: () => _drawerKey.currentState!.openDrawer(),
                  )
                : null,
            body: _currentDestination != null
                ? TransparentStatusBar(
                    brightness: Brightness.dark,
                    child: UserDataRefresher(
                      child: ConnectivityAlert(
                        child: SafeArea(
                          child: Notice(
                            child: _AnimatedIndexedStack(
                              index: _destinations.indexOfDestination(
                                _currentDestination!,
                              )!,
                              children: _destinations.pagesOnly,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  final NavigationDestination? currentDestination;
  final ValueChanged<NavigationDestination> onTap;
  final VoidCallback onMenuOpen;
  final List<NavigationDestination> destinations;

  const _BottomNavigationBar({
    Key? key,
    required this.destinations,
    required this.currentDestination,
    required this.onTap,
    required this.onMenuOpen,
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
        type: BottomNavigationBarType.fixed,
        iconSize: 24,
        selectedFontSize: 9,
        selectedItemColor: context.brand.theme.colors.primary,
        unselectedFontSize: 9,
        unselectedItemColor: context.brand.theme.colors.grey1,
        currentIndex: destinations.adjustedIndexOf(currentDestination),
        onTap: (index) =>
            index == 0 ? onMenuOpen() : onTap(destinations[index - 1]),
        items: [
          BottomNavigationBarItem(
            icon: const _BottomNavigationBarIcon(VialerSans.burger),
            label: context.msg.main.navigation.drawer.title,
          ),
          ...destinations.map(
            (navigationDestination) => BottomNavigationBarItem(
              icon: _BottomNavigationBarIcon(
                navigationDestination.asIconData(),
              ),
              label: navigationDestination.asLabel(context),
            ),
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

class _DialerFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _DialerFloatingActionButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      width: 62,
      child: FloatingActionButton(
        // We use the CallButton's hero tag for a nice
        // transition between the dialer and call button.
        heroTag: CallButton.defaultHeroTag,
        backgroundColor: context.brand.theme.colors.green1,
        onPressed: onPressed,
        child: const Icon(VialerSans.dialpad, size: 31),
      ),
    );
  }
}

extension on List<DestinationPage> {
  DestinationPage? whereNavigationDestinationIs(
    NavigationDestination navigationDestination,
  ) =>
      where(
        (element) => element.destination == navigationDestination,
      ).firstOrNull;

  int? indexOfDestination(NavigationDestination destination) {
    final navigationDestination = whereNavigationDestinationIs(destination);

    if (navigationDestination == null) return null;

    return contains(navigationDestination)
        ? indexOf(navigationDestination)
        : null;
  }

  List<Widget> get pagesOnly => map((e) => e.page).toList();
}

extension on List<NavigationDestination>? {
  int adjustedIndexOf(NavigationDestination? destination) {
    if (this == null || destination == null) return 0;

    return this!.contains(destination) ? this!.indexOf(destination) + 1 : 0;
  }
}

/// This is a struct to associate a page with a given destination.
class DestinationPage {
  final NavigationDestination destination;
  final Widget page;

  const DestinationPage(this.destination, this.page);
}
