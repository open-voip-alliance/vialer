import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/models/onboarding/auto_login.dart';
import '../../../../../data/models/voipgrid/web_page.dart';
import '../../../../../domain/usecases/metrics/track_web_view.dart';
import '../../../../../domain/usecases/voipgrid/get_web_page_url.dart';
import '../../../util/loggable.dart';
import 'state.dart';

class WebViewCubit extends Cubit<WebViewState> with Loggable {
  WebViewCubit(this._page) : super(LoadingUrl()) {
    unawaited(_loadUrl());
  }

  final _getWebViewUrl = GetWebPageUrlUseCase();
  final _trackWebView = TrackWebViewUseCase();

  final WebPage _page;

  void reload() {
    emit(LoadingUrl());
    unawaited(_loadUrl());
  }

  void notifyWebViewLoaded(String url) {
    emit(LoadedWebView(url: url));
  }

  void notifyWebViewHadError(int code, String message) {
    logger.info('Error loading url, $code: $message');

    emit(LoadWebViewError(description: message));
  }

  Future<void> _loadUrl() async {
    try {
      final url = await _getWebViewUrl(page: _page);

      _trackWebView(page: _page.name);

      emit(LoadedUrl(url: url));
    } on AutoLoginException {
      emit(LoadPortalUrlError());
    }
  }
}
