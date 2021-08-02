import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/contact.dart';
import '../../resources/localizations.dart';
import '../../resources/theme.dart';
import '../../routes.dart';
import '../../util/brand.dart';
import '../../widgets/transparent_status_bar.dart';
import 'call/widgets/call_button.dart';
import 'contacts/cubit.dart';
import 'contacts/details/page.dart';
import 'contacts/page.dart';
import 'dialer/page.dart';
import 'recent/page.dart';
import 'settings/page.dart';
import 'widgets/caller.dart';
import 'widgets/connectivity_alert.dart';
import 'widgets/notice/widget.dart';
import 'widgets/user_data_refresher/widget.dart';

typedef WidgetWithArgumentsBuilder = Widget Function(BuildContext, Object?);

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int? _currentIndex;
  int? _previousIndex;

  List<Widget>? _pages;

  bool _dialerIsPage = false;

  final _navigatorStates = [
    GlobalKey<NavigatorState>(),
  ];

  void _navigateTo(int? index) {
    if (index == null) return;

    _previousIndex = _currentIndex;

    setState(() {
      _currentIndex = index;

      if (context.isAndroid) {
        for (final state in _navigatorStates) {
          state.currentState!.popUntil(ModalRoute.withName('/'));
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only on iOS is the dialer a separate bottom nav page.
    _dialerIsPage = context.isIOS;

    if (_pages == null) {
      _pages = [
        if (_dialerIsPage) const DialerPage(isInBottomNavBar: true),
        BlocProvider<ContactsCubit>(
          create: (_) => ContactsCubit(),
          child: _Navigator(
            navigatorKey: _navigatorStates[0],
            routes: {
              ContactsPageRoutes.root: (_, __) =>
                  ContactsPage(bottomLettersPadding: !_dialerIsPage ? 96 : 0),
              ContactsPageRoutes.details: (_, contact) =>
                  ContactDetailsPage(contact: contact as Contact),
            },
          ),
        ),
        RecentCallsPage(
          listBottomPadding: !_dialerIsPage ? 96 : 0,
          snackBarRightPadding: !_dialerIsPage ? 72 : 0,
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
    return BlocListener<CallerCubit, CallerState>(
      listener: _onCallerStateChanged,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButton: _currentIndex != 2 && !_dialerIsPage
            ? SizedBox(
                height: 62,
                width: 62,
                child: FloatingActionButton(
                  // We use the CallButton's hero tag for a nice transition
                  // between the dialer and call button.
                  heroTag: CallButton.defaultHeroTag,
                  backgroundColor: context.brand.theme.green1,
                  onPressed: () => Navigator.pushNamed(context, Routes.dialer),
                  child: const Icon(VialerSans.dialpad, size: 31),
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
            color: context.brand.theme.grey2,
          ),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 24,
        selectedFontSize: 9,
        selectedItemColor: context.brand.theme.primary,
        unselectedFontSize: 9,
        unselectedItemColor: context.brand.theme.grey1,
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

class _Navigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Map<String, WidgetWithArgumentsBuilder> routes;

  _Navigator({
    Key? key,
    required this.routes,
    required this.navigatorKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !await navigatorKey.currentState!.maybePop(),
      child: Navigator(
        key: navigatorKey,
        initialRoute: routes.keys.first,
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (context) => routes[settings.name]!(
            context,
            settings.arguments,
          ),
        ),
      ),
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
