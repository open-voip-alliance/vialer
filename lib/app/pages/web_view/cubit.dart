import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/platform_interface.dart';

import '../../../domain/metrics/track_web_view.dart';
import '../../../domain/onboarding/auto_login.dart';
import '../../../domain/voipgrid/get_web_page_url.dart';
import '../../../domain/voipgrid/web_page.dart';
import '../../util/loggable.dart';
import 'state.dart';

class WebViewCubit extends Cubit<WebViewState> with Loggable {
  final _getWebViewUrl = GetWebPageUrlUseCase();
  final _trackWebView = TrackWebViewUseCase();

  final WebPage _page;

  WebViewCubit(this._page) : super(LoadingUrl()) {
    _loadUrl();
  }

  void reload() {
    emit(LoadingUrl());
    _loadUrl();
  }

  void notifyWebViewLoaded(String url) {
    emit(LoadedWebView(url: url));
  }

  void notifyWebViewHadError(WebResourceError error) {
    logger.info('Error loading url, ${error.errorCode}: ${error.description}');

    emit(LoadWebViewError(description: error.description));
  }

  void _loadUrl() async {
    try {
      final url = await _getWebViewUrl(page: _page);

      _trackWebView(page: describeEnum(_page));

      emit(LoadedUrl(url: url));
    } on AutoLoginException {
      emit(LoadPortalUrlError());
    }
  }
}
