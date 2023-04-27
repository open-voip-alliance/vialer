import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewController, {super.key});

  final InAppWebViewController? _webViewController;

  bool get _webviewIsReady => _webViewController != null;

  Future<void> _onBackButtonPressed() async {
    if (await _webViewController!.canGoBack()) {
      unawaited(_webViewController!.goBack());
    }
  }

  Future<void> _onForwardButtonPressed() async {
    if (await _webViewController!.canGoForward()) {
      unawaited(_webViewController!.goForward());
    }
  }

  void _onReloadButtonPressed() {
    _webViewController!.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.angleLeft),
          onPressed: _webviewIsReady ? _onBackButtonPressed : null,
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.angleRight),
          onPressed: _webviewIsReady ? _onForwardButtonPressed : null,
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowsRotate),
          onPressed: _webviewIsReady ? _onReloadButtonPressed : null,
        ),
      ],
    );
  }
}
