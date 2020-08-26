import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_segment/flutter_segment.dart';

import '../widgets/caller.dart';

import '../../../../domain/entities/call.dart';

import '../../../util/debug.dart';

import 'presenter.dart';

class RecentController extends Controller {
  final _presenter = RecentPresenter();

  var recentCalls = <Call>[];

  int _extraPagesLoaded = 0;
  final _maxAmountOfExtraPages = 2; // 3 months in total.

  bool _loadingMoreRecents = false;
  Completer _refreshCompleter;

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);

    _loadInitialRecents();
  }

  bool get _loadedMaxAmountOfExtraPages {
    return _extraPagesLoaded == _maxAmountOfExtraPages;
  }

  Future<void> call(String destination) async {
    doIfNotDebug(() {
      Segment.track(eventName: 'call', properties: {'via': 'recent'});
    });

    getContext().bloc<CallerCubit>().call(destination);
  }

  void copyNumber(String number) {
    doIfNotDebug(() {
      Segment.track(eventName: 'copy-number');
    });

    Clipboard.setData(ClipboardData(text: number));
  }

  void _loadInitialRecents() {
    logger.info('Loading initial recents calls');
    _getRecentCalls(page: 0);
  }

  Future<void> refreshRecents() {
    logger.info('Refreshing recent calls');
    _refreshCompleter = Completer();

    _getRecentCalls(page: 0);

    return _refreshCompleter.future;
  }

  void loadMoreRecents() {
    if (!_loadedMaxAmountOfExtraPages && !_loadingMoreRecents) {
      logger.info('Loading more recents calls');

      _loadingMoreRecents = true;

      _getRecentCalls(page: _extraPagesLoaded + 1);
    }
  }

  void _getRecentCalls({@required int page}) {
    _presenter.getRecentCalls(page: page);
  }

  void _onRecentCallsUpdated(List<Call> recentCalls) {
    if (_loadingMoreRecents) {
      // We are loading more so add them at the end of the list.
      this.recentCalls.addAll(recentCalls);
      _extraPagesLoaded++;
    } else {
      // We are refreshing or loading for the first time
      // so add them at the start of the list.
      this.recentCalls.insertAll(0, recentCalls);
    }

    // Remove duplicate calls.
    this.recentCalls = this.recentCalls.toSet().toList();

    refreshUI();

    _loadingMoreRecents = false;
    _refreshCompleter?.complete();
    _refreshCompleter = null;
  }

  void _onRecentCallsError(_) {
    _loadingMoreRecents = false;
  }

  @override
  void onResumed() {
    super.onResumed();
    _loadInitialRecents();
  }

  @override
  void initListeners() {
    _presenter.recentCallsOnNext = _onRecentCallsUpdated;
    _presenter.recentCallsOnError = _onRecentCallsError;
  }
}
