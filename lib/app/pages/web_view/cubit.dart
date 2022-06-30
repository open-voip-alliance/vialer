import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/platform_interface.dart';

import '../../../dependency_locator.dart';
import '../../../domain/entities/exceptions/auto_login.dart';
import '../../../domain/entities/navigation_destination.dart';
import '../../../domain/entities/web_page.dart';
import '../../../domain/events/event_bus.dart';
import '../../../domain/events/user_did_navigate.dart';
import '../../../domain/usecases/get_web_page_url.dart';
import '../../../domain/usecases/metrics/track_web_view.dart';
import '../../util/loggable.dart';
import 'state.dart';

class WebViewCubit extends Cubit<WebViewState> with Loggable {
  final _getWebViewUrl = GetWebPageUrlUseCase();
  final _trackWebView = TrackWebViewUseCase();
  final _eventBus = dependencyLocator<EventBusObserver>();

  final WebPage _page;

  WebViewCubit(this._page) : super(LoadingUrl()) {
    _listenForNavigation();
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

  /// We want WebViews to refresh whenever the user navigates to one so the
  /// data is current and the login session is refreshed.
  void _listenForNavigation() {
    _eventBus.on<UserDidNavigate>((event) {
      if (_page.matchesNavigationDestination(event.to)) {
        reload();
      }
    });
  }
}

extension on WebPage {
  bool matchesNavigationDestination(NavigationDestination destination) {
    const mapping = {
      WebPage.stats : NavigationDestination.stats,
      WebPage.dialPlan : NavigationDestination.dialPlan,
      WebPage.calls : NavigationDestination.calls,
    };

    return mapping[this] == destination;
  }
}
