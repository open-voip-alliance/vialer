import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:flutter_segment/flutter_segment.dart';

import '../dialer/caller.dart';

import '../../../../domain/entities/call.dart';

import '../../../../domain/repositories/call.dart';
import '../../../../domain/repositories/recent_call.dart';
import '../../../../domain/repositories/logging.dart';
import '../../../../domain/repositories/setting.dart';

import '../../../util/debug.dart';

import 'presenter.dart';

class RecentController extends Controller with Caller {
  @override
  final CallRepository callRepository;

  @override
  final SettingRepository settingRepository;

  @override
  final LoggingRepository loggingRepository;

  final RecentPresenter _presenter;

  final recentCalls = <Call>[];

  final scrollController = ScrollController();

  Completer _completer;

  RecentController(
    RecentCallRepository recentCallRepository,
    this.callRepository,
    this.settingRepository,
    this.loggingRepository,
  ) : _presenter = RecentPresenter(
          recentCallRepository,
          callRepository,
          settingRepository,
        );

  int _page = 0;

  int _emptyCount = 0;

  bool _endReached = false;
  bool _loading = false;

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);

    getRecentCalls();
    executeGetSettingsUseCase();

    scrollController.addListener(() {
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.position.pixels;

      if (!_endReached && !_loading && currentScroll >= maxScroll - 300) {
        logger.info('Requesting recent calls');
        _loading = true;
        getRecentCalls();
      }
    });
  }

  @override
  Future<void> call(String destination) async {
    doIfNotDebug(() {
      Segment.track(eventName: 'call', properties: {'via': 'recent'});
    });
    super.call(destination);
  }

  void copyNumber(String number) {
    doIfNotDebug(() {
      Segment.track(eventName: 'copy-number');
    });

    Clipboard.setData(ClipboardData(text: number));
  }

  @override
  void executeCallUseCase(String destination) => _presenter.call(destination);

  Future<void> updateRecents() {
    _completer = Completer();

    getRecentCalls();

    return _completer.future;
  }

  void getRecentCalls() {
    _presenter.getRecentCalls(page: _page);
    _page++;
  }

  void _onRecentCallsUpdated(List<Call> recentCalls) {
    if (recentCalls.isEmpty) {
      _emptyCount++;

      if (_emptyCount >= 3) {
        logger.info('End reached');
        _endReached = true;
      }

      if (!_endReached) {
        getRecentCalls();
      }
    } else {
      _emptyCount = 0;
    }

    this.recentCalls.addAll(recentCalls);

    _loading = false;
    refreshUI();

    _completer?.complete();
  }

  @override
  void onResumed() {
    super.onResumed();
    getRecentCalls();
  }

  @override
  void initListeners() {
    _presenter.recentCallsOnNext = _onRecentCallsUpdated;
    _presenter.callOnError = showException;
    _presenter.settingsOnNext = setSettings;
  }

  @override
  void executeGetSettingsUseCase() => _presenter.getSettings();
}
