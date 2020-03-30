import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/recent_call.dart';

import '../widgets/header.dart';
import 'controller.dart';
import 'widgets/item.dart';

import '../../../resources/localizations.dart';

class RecentPage extends View {
  final RecentCallRepository _recentCallRepository;
  final double listBottomPadding;

  RecentPage(
    this._recentCallRepository, {
    Key key,
    this.listBottomPadding = 0,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _RecentPageState(_recentCallRepository);
}

class _RecentPageState extends ViewState<RecentPage, RecentController> {
  _RecentPageState(RecentCallRepository recentCallRepository)
      : super(RecentController(recentCallRepository));

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
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16).copyWith(
                    bottom: widget.listBottomPadding,
                  ),
                  itemCount: controller.recentCalls.length,
                  itemBuilder: (context, index) {
                    return RecentCallItem(
                      call: controller.recentCalls[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
