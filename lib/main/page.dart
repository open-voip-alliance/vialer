import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../resources/theme.dart';
import 'recent/page.dart';
import '../widgets/transparent_status_bar.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex;

  List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _currentIndex = 1;

    _pages = [
      ListView(
        children: List.generate(
          128,
          (i) => Text(i.toString(), style: TextStyle(fontSize: 24)),
        ),
      ),
      RecentPage.create(),
      Container(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SizedBox(
        height: 62,
        width: 62,
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(Icons.dialpad, size: 31.5),
        ),
      ),
      bottomNavigationBar: _BottomNavigationBar(
        currentIndex: _currentIndex,
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

  const _BottomNavigationBar({
    Key key,
    this.currentIndex,
    this.onTap,
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
        iconSize: 24,
        selectedFontSize: 9,
        unselectedFontSize: 9,
        unselectedItemColor: VialerColors.grey1,
        currentIndex: currentIndex,
        onTap: onTap,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            title: _BottomNavigationBarText('Contacts'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            title: _BottomNavigationBarText('Recent'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
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
