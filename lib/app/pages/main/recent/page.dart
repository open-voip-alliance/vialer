import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/call.dart';
import '../../../../domain/repositories/recent_call.dart';

import '../../../resources/theme.dart';
import '../../../resources/localizations.dart';

import '../widgets/header.dart';
import '../widgets/list_placeholder.dart';
import 'widgets/item.dart';

import 'controller.dart';

class RecentPage extends View {
  final RecentCallRepository _recentCallRepository;
  final CallRepository _callRepository;

  final double listBottomPadding;

  RecentPage(
    this._recentCallRepository,
    this._callRepository, {
    Key key,
    this.listBottomPadding = 0,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _RecentPageState(_recentCallRepository, _callRepository);
}

class _RecentPageState extends ViewState<RecentPage, RecentController> {
  _RecentPageState(
    RecentCallRepository recentCallRepository,
    CallRepository callRepository,
  ) : super(RecentController(recentCallRepository, callRepository));

  @override
  Widget buildPage() {
    return Scaffold(
      key: globalKey,
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
                child: ConditionalPlaceholder(
                  showPlaceholder: controller.recentCalls.isEmpty,
                  placeholder: ListPlaceholder(
                    icon: Icon(VialerSans.missedCall),
                    title: Text(context.msg.main.recent.list.empty.title),
                    description: Text(
                      context.msg.main.recent.list.empty.description,
                    ),
                  ),
                  child: ListView.builder(
                    controller: controller.scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16).copyWith(
                      bottom: widget.listBottomPadding,
                    ),
                    itemCount: controller.recentCalls.length,
                    itemBuilder: (context, index) {
                      final call = controller.recentCalls[index];
                      return RecentCallItem(
                        call: call,
                        onPressed: () {
                          controller.call(call.destinationNumber);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
