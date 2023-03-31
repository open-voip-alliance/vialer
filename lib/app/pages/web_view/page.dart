import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

import './cubit.dart';
import './state.dart';
import './widgets/navigation_controls.dart';
import '../../../domain/voipgrid/web_page.dart';
import '../../pages/main/widgets/conditional_placeholder.dart';
import '../../resources/localizations.dart';
import '../../util/conditional_capitalization.dart';
import '../../widgets/stylized_button.dart';

class WebViewPage extends StatefulWidget {
  final WebPage page;

  WebViewPage(this.page);

  static Future route(BuildContext context, {required WebPage to}) =>
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => WebViewPage(to),
        ),
      );

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  void _onTryAgainButtonPressed(BuildContext context) {
    setState(() {
      _controller = null;
    });

    context.read<WebViewCubit>().reload();
  }

  void _onWebViewCreated(WebViewController controller) {
    setState(() {
      _controller = controller;
    });
  }

  void _onPageFinishedLoading(BuildContext context, String url) {
    context.read<WebViewCubit>().notifyWebViewLoaded(url);
  }

  void _onPageLoadError(BuildContext context, WebResourceError error) {
    context.read<WebViewCubit>().notifyWebViewHadError(error);
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
                  StylizedButton.raised(
                    colored: true,
                    onPressed: () => _onTryAgainButtonPressed(context),
                    child: Text(
                      context.msg.generic.button.tryAgain
                          .toUpperCaseIfAndroid(context),
                    ),
                  ),
                ],
              );
            }
            if (state is LoadedUrl) {
              return Stack(
                children: [
                  WebView(
                    initialUrl: state.url,
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: _onWebViewCreated,
                    onPageFinished: (_) => _onPageFinishedLoading(
                      context,
                      state.url,
                    ),
                    onWebResourceError: (error) =>
                        _onPageLoadError(context, error),
                    gestureNavigationEnabled: true,
                  ),
                  if (state is! LoadedWebView)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
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
