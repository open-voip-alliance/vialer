import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/call.dart';
import '../../../../domain/repositories/recent_call.dart';
import '../../../../domain/repositories/logging.dart';
import '../../../../domain/repositories/setting.dart';

import '../../../resources/theme.dart';
import '../../../resources/localizations.dart';

import '../widgets/header.dart';
import '../widgets/list_placeholder.dart';
import 'widgets/item.dart';

import '../util/stylized_snack_bar.dart';

import 'controller.dart';

class RecentPage extends View {
  final RecentCallRepository _recentCallRepository;
  final CallRepository _callRepository;
  final SettingRepository _settingRepository;
  final LoggingRepository _loggingRepository;

  final double listBottomPadding;
  final double snackBarRightPadding;

  RecentPage(
    this._recentCallRepository,
    this._callRepository,
    this._settingRepository,
    this._loggingRepository, {
    Key key,
    this.listBottomPadding = 0,
    this.snackBarRightPadding = 0,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecentPageState(
        _recentCallRepository,
        _callRepository,
        _settingRepository,
        _loggingRepository,
      );
}

class _RecentPageState extends ViewState<RecentPage, RecentController> {
  _RecentPageState(
    RecentCallRepository recentCallRepository,
    CallRepository callRepository,
    SettingRepository settingRepository,
    LoggingRepository loggingRepository,
  ) : super(
          RecentController(
            recentCallRepository,
            callRepository,
            settingRepository,
            loggingRepository,
          ),
        );

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_handleScrolling);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _handleScrolling() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 200) {
      controller.loadMoreRecents();
    }
  }

  void _showSnackBar(BuildContext context) {
    showSnackBar(
      context,
      text: context.msg.main.recent.snackBar.copied,
      padding: EdgeInsets.only(
        right: widget.snackBarRightPadding,
      ),
    );
  }

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
                  child: RefreshIndicator(
                    onRefresh: controller.refreshRecents,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      padding: EdgeInsets.only(
                        bottom: widget.listBottomPadding,
                      ),
                      itemCount: controller.recentCalls.length,
                      itemBuilder: (context, index) {
                        final call = controller.recentCalls[index];
                        return RecentCallItem(
                          call: call,
                          onCallPressed: () {
                            controller.call(call.destinationNumber);
                          },
                          onCopyPressed: () {
                            controller.copyNumber(call.destinationNumber);
                            _showSnackBar(context);
                          },
                        );
                      },
                    ),
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
