import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../data/models/voipgrid/web_page.dart';
import '../../features/settings/widgets/settings_button.dart';
import '../../resources/localizations.dart';
import '../controllers/web_view/cubit.dart';
import '../controllers/web_view/state.dart';
import '../widgets/conditional_placeholder.dart';
import '../widgets/web_view/navigation_controls.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage(this.page, {super.key});

  final WebPage page;

  static MaterialPageRoute<void> route(WebPage page) => MaterialPageRoute(
        builder: (context) => WebViewPage(page),
      );

  static Future<void> open(BuildContext context, {required WebPage to}) =>
      Navigator.of(context, rootNavigator: true).push(route(to));

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final _settings = InAppWebViewSettings(
    clearCache: true,
    useOnDownloadStart: true,
    transparentBackground: true,
    useHybridComposition: true,
    geolocationEnabled: false,
  );

  InAppWebViewController? _controller;

  void _onTryAgainButtonPressed(BuildContext context) {
    setState(() {
      _controller = null;
    });

    context.read<WebViewCubit>().reload();
  }

  void _onWebViewCreated(InAppWebViewController controller) {
    setState(() {
      _controller = controller;
    });
  }

  void _onProgressChanged(BuildContext context, int progress, String url) {
    if (progress == 100) {
      context.read<WebViewCubit>().notifyWebViewLoaded(url);
    }
  }

  void _onPageLoadError(BuildContext context, int code, String message) {
    context.read<WebViewCubit>().notifyWebViewHadError(code, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          NavigationControls(_controller),
        ],
      ),
      body: BlocProvider<WebViewCubit>(
        create: (_) => WebViewCubit(widget.page),
        child: BlocBuilder<WebViewCubit, WebViewState>(
          builder: (context, state) {
            if (state is LoadPortalUrlError || state is LoadWebViewError) {
              return Warning(
                description: Text(context.msg.webview.error.description),
                icon: const FaIcon(FontAwesomeIcons.exclamation),
                title: Text(context.msg.webview.error.title),
                children: [
                  const SizedBox(height: 16),
                  SettingsButton(
                    onPressed: () => _onTryAgainButtonPressed(context),
                    text: context.msg.generic.button.tryAgain,
                  ),
                ],
              );
            }
            if (state.isLoaded) {
              return Stack(
                children: [
                  InAppWebView(
                    key: Key(state.url),
                    initialUrlRequest: URLRequest(url: WebUri(state.url)),
                    initialSettings: _settings,
                    onWebViewCreated: _onWebViewCreated,
                    onReceivedHttpError: (_, __, error) => _onPageLoadError(
                      context,
                      error.statusCode ?? 0,
                      error.reasonPhrase ?? '',
                    ),
                    onProgressChanged: (_, progress) => _onProgressChanged(
                      context,
                      progress,
                      state.url,
                    ),
                    onPermissionRequest: (_, request) async =>
                        PermissionResponse(
                      action: PermissionResponseAction.GRANT,
                      resources: request.resources,
                    ),
                  ),
                  if (state is! LoadedWebView)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
