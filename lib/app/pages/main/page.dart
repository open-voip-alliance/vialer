import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../resources/theme.dart';
import '../../routes.dart';
import 'dialer/page.dart';
import 'contacts/page.dart';
import 'recent/page.dart';
import '../../widgets/transparent_status_bar.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex;

  List<Widget> _pages;

  bool _dialerIsPage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _dialerIsPage = context.isIOS;

    if (_pages == null) {
      _pages = [
        if (_dialerIsPage) DialerPage(),
        ContactsPage(bottomLettersPadding: !_dialerIsPage ? 96 : 0),
        RecentPage(),
        Container(),
      ];
    }

    if (_currentIndex == null) {
      _currentIndex = _dialerIsPage ? 2 : 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: !_dialerIsPage
          ? SizedBox(
              height: 62,
              width: 62,
              child: FloatingActionButton(
                backgroundColor: VialerColors.green1,
                onPressed: () => Navigator.pushNamed(context, Routes.dialer),
                child: Icon(VialerSans.dialpad, size: 31),
              ),
            )
          : null,
      bottomNavigationBar: _BottomNavigationBar(
        currentIndex: _currentIndex,
        dialerIsPage: _dialerIsPage,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
      body: TransparentStatusBar(
        brightness: Brightness.dark,
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 100),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation.drive(
                Tween(begin: 0.9, end: 1.0),
              ),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: _pages[_currentIndex],
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
            color: VialerColors.grey2,
          ),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 24,
        selectedFontSize: 9,
        selectedItemColor: VialerColors.primary,
        unselectedFontSize: 9,
        unselectedItemColor: VialerColors.grey1,
        currentIndex: currentIndex,
        onTap: onTap,
        items: [
          if (dialerIsPage)
            BottomNavigationBarItem(
              icon: Icon(VialerSans.dialpad),
              title: _BottomNavigationBarText('Keypad'),
            ),
          BottomNavigationBarItem(
            icon: Icon(VialerSans.contacts),
            title: _BottomNavigationBarText('Contacts'),
          ),
          BottomNavigationBarItem(
            icon: Icon(VialerSans.clock),
            title: _BottomNavigationBarText('Recent'),
          ),
          BottomNavigationBarItem(
            icon: Icon(VialerSans.settings),
            title: _BottomNavigationBarText('Settings'),
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
