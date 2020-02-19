import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/recent_call_repository.dart';
import '../../../../domain/entities/recent_call.dart';

import 'presenter.dart';

class RecentController extends Controller {
  final RecentPresenter _presenter;

  List<RecentCall> recentCalls = [];

  RecentController(RecentCallRepository recentCallRepository)
      : _presenter = RecentPresenter(recentCallRepository);

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);

    getRecentCalls();
  }

  void getRecentCalls() {
    _presenter.getRecentCalls();
  }

  void _onRecentCallsUpdated(List<RecentCall> recentCalls) {
    this.recentCalls = recentCalls;

    refreshUI();
  }

  @override
  void initListeners() {
    _presenter.recentCallsOnNext = _onRecentCallsUpdated;
  }
}
