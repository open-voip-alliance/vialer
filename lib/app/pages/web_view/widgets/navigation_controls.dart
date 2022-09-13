import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NavigationControls extends StatelessWidget {
  final WebViewController? _webViewController;

  const NavigationControls(this._webViewController);

  bool get _webviewIsReady {
    return _webViewController != null;
  }

  void _onBackButtonPressed() async {
    if (await _webViewController!.canGoBack()) {
      await _webViewController!.goBack();
    }
  }

  void _onForwardButtonPressed() async {
    if (await _webViewController!.canGoForward()) {
      await _webViewController!.goForward();
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
