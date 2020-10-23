import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String data;

  const Header(this.data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        data,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 38,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
