import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_segment/flutter_segment.dart';

import '../../pages/webview/state.dart';
import '../../util/debug.dart';
import '../../util/loggable.dart';

import '../../../domain/entities/exceptions/auto_login.dart';
import '../../../domain/entities/portal_page.dart';
import '../../../domain/usecases/get_portal_webview_url.dart';

class PortalWebViewCubit extends Cubit<PortalWebViewState> with Loggable {
  final getPortalWebviewUrl = GetPortalWebviewUrlUseCase();
  final PortalPage _portalPage;

  PortalWebViewCubit(this._portalPage) : super(LoadingPortalUrl()) {
    _loadPortalUrl();
  }

  void reloadAll() {
    emit(LoadingPortalUrl());
    _loadPortalUrl();
  }

  void notifyWebviewLoaded(String portalUrl) {
    emit(LoadedWebview(portalUrl: portalUrl));
  }

  void notifyWebviewHadError() {
    emit(LoadWebviewError());
  }

  void _loadPortalUrl() async {
    try {
      final url = await getPortalWebviewUrl(page: _portalPage);

      doIfNotDebug(() {
        Segment.track(
          eventName: 'webview',
          properties: {
            'page': describeEnum(_portalPage),
          },
        );
      });

      emit(LoadedPortalUrl(portalUrl: url));
    } on AutoLoginException {
      emit(LoadPortalUrlError());
    }
  }
}
