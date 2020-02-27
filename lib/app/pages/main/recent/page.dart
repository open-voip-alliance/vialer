import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import '../../../../data/repositories/recent_call.dart';

import '../widgets/header.dart';
import 'controller.dart';
import 'widgets/item.dart';

import '../../../resources/localizations.dart';

class RecentPage extends View {
  RecentPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecentPageState();
}

class _RecentPageState extends ViewState<RecentPage, RecentController> {
  _RecentPageState() : super(RecentController(DataRecentCallRepository()));

  @override
  Widget buildPage() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Header(context.msg.main.recent.title),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: controller.recentCalls
                      .map((item) => RecentCallItem(item: item))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
