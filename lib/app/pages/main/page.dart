import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../domain/repositories/call.dart';
import '../../../domain/repositories/permission.dart';
import '../../../domain/repositories/contact.dart';
import '../../../domain/repositories/recent_call.dart';
import '../../../domain/repositories/setting.dart';
import '../../../domain/repositories/build_info.dart';
import '../../../domain/repositories/logging.dart';
import '../../../domain/repositories/storage.dart';

import '../../resources/theme.dart';
import '../../resources/localizations.dart';
import '../../routes.dart';

import 'contacts/details/page.dart';
import 'dialer/page.dart';
import 'contacts/page.dart';
import 'recent/page.dart';
import 'settings/page.dart';

import '../../widgets/transparent_status_bar.dart';

typedef WidgetWithArgumentsBuilder = Widget Function(BuildContext, Object);

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex;

  List<Widget> _pages;

  bool _dialerIsPage;

  final _navigatorStates = [
    GlobalKey<NavigatorState>(),
  ];

  void _navigateTo(int index) {
    setState(() {
      _currentIndex = index;

      if (context.isAndroid) {
        for (final state in _navigatorStates) {
          state.currentState.popUntil(ModalRoute.withName('/'));
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _dialerIsPage = context.isIOS;

    if (_pages == null) {
      _pages = [
        if (_dialerIsPage)
          DialerPage(
            Provider.of<CallRepository>(context),
            Provider.of<PermissionRepository>(context),
            Provider.of<StorageRepository>(context),
          ),
        _Navigator(
          navigatorKey: _navigatorStates[0],
          routes: {
            ContactsPageRoutes.root: (_, __) => ContactsPage(
                  Provider.of<ContactRepository>(context),
                  Provider.of<PermissionRepository>(context),
                  bottomLettersPadding: !_dialerIsPage ? 96 : 0,
                ),
            ContactsPageRoutes.details: (_, contact) => ContactDetailsPage(
                  Provider.of<ContactRepository>(context),
                  Provider.of<CallRepository>(context),
                  Provider.of<PermissionRepository>(context),
                  contact: contact,
                ),
          },
        ),
        RecentPage(
          Provider.of<RecentCallRepository>(context),
          Provider.of<CallRepository>(context),
          listBottomPadding: !_dialerIsPage ? 96 : 0,
          snackBarRightPadding: !_dialerIsPage ? 72 : 0,
        ),
        SettingsPage(
          Provider.of<SettingRepository>(context),
          Provider.of<BuildInfoRepository>(context),
          Provider.of<LoggingRepository>(context),
          Provider.of<StorageRepository>(context),
        ),
      ];
    }

    if (_currentIndex == null) {
      _currentIndex = _dialerIsPage ? 2 : 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _currentIndex != 2 && !_dialerIsPage
          ? SizedBox(
              height: 62,
              width: 62,
              child: FloatingActionButton(
                backgroundColor: context.brandTheme.green1,
                onPressed: () => Navigator.pushNamed(context, Routes.dialer),
                child: Icon(VialerSans.dialpad, size: 31),
              ),
            )
          : null,
      bottomNavigationBar: _BottomNavigationBar(
        currentIndex: _currentIndex,
        dialerIsPage: _dialerIsPage,
        onTap: _navigateTo,
      ),
      body: TransparentStatusBar(
        brightness: Brightness.dark,
        child: _AnimatedIndexedStack(
          index: _currentIndex,
          children: _pages,
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
    Key key,
    this.currentIndex,
    this.onTap,
    this.dialerIsPage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: context.brandTheme.grey2,
          ),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 24,
        selectedFontSize: 9,
        selectedItemColor: context.brandTheme.primary,
        unselectedFontSize: 9,
        unselectedItemColor: context.brandTheme.grey1,
        currentIndex: currentIndex,
        onTap: onTap,
        items: [
          if (dialerIsPage)
            BottomNavigationBarItem(
              icon: Icon(VialerSans.dialpad),
              title: _BottomNavigationBarText(
                context.msg.main.dialer.menu.title,
              ),
            ),
          BottomNavigationBarItem(
            icon: Icon(VialerSans.contacts),
            title: _BottomNavigationBarText(
              context.msg.main.contacts.menu.title,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(VialerSans.clock),
            title: _BottomNavigationBarText(
              context.msg.main.recent.menu.title,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(VialerSans.settings),
            title: _BottomNavigationBarText(
              context.msg.main.settings.menu.title,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigationBarText extends StatelessWidget {
  final String data;

  const _BottomNavigationBarText(this.data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: Text(data),
    );
  }
}

class _Navigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Map<String, WidgetWithArgumentsBuilder> routes;

  _Navigator({
    Key key,
    @required this.routes,
    this.navigatorKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !await navigatorKey.currentState.maybePop(),
      child: Navigator(
        key: navigatorKey,
        initialRoute: routes.keys.first,
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (context) => routes[settings.name](
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
    Key key,
    this.index,
    this.children = const [],
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnimatedIndexedStackState();
}

class _AnimatedIndexedStackState extends State<_AnimatedIndexedStack>
    with TickerProviderStateMixin {
  AnimationController _controller;

  bool _animating = false;
  int _previousIndex;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 100),
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
