import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/exceptions/auto_login.dart';
import '../../../domain/entities/portal_page.dart';
import '../../../domain/usecases/get_portal_webview_url.dart';
import '../../../domain/usecases/metrics/track_web_view.dart';
import '../../util/loggable.dart';
import 'state.dart';

class PortalWebViewCubit extends Cubit<PortalWebViewState> with Loggable {
  final _getPortalWebviewUrl = GetPortalWebViewUrlUseCase();
  final _trackWebView = TrackWebViewUseCase();

  final PortalPage _portalPage;

  PortalWebViewCubit(this._portalPage) : super(LoadingPortalUrl()) {
    _loadPortalUrl();
  }

  void reloadAll() {
    emit(LoadingPortalUrl());
    _loadPortalUrl();
  }

  void notifyWebViewLoaded(String portalUrl) {
    emit(LoadedWebview(portalUrl: portalUrl));
  }

  void notifyWebViewHadError() {
    emit(LoadWebviewError());
  }

  void _loadPortalUrl() async {
    try {
      final url = await _getPortalWebviewUrl(page: _portalPage);

      _trackWebView(page: describeEnum(_portalPage));

      emit(LoadedPortalUrl(portalUrl: url));
    } on AutoLoginException {
      emit(LoadPortalUrlError());
    }
  }
}
