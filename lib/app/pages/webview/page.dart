import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../domain/entities/portal_page.dart';

import '../../pages/main/widgets/conditional_placeholder.dart';
import '../../resources/localizations.dart';
import '../../resources/theme.dart';
import '../../util/conditional_capitalization.dart';
import '../../widgets/stylized_button.dart';

import './cubit.dart';
import './state.dart';
import './widgets/navigation_controls.dart';

class PortalWebViewPage extends StatefulWidget {
  final PortalPage portalPage;

  PortalWebViewPage(this.portalPage);

  @override
  _PortalWebViewPageState createState() => _PortalWebViewPageState();
}

class _PortalWebViewPageState extends State<PortalWebViewPage> {
  WebViewController _controller;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  void _onTryAgainButtonPressed(BuildContext context) {
    setState(() {
      _controller = null;
    });
    context.read<PortalWebViewCubit>().reloadAll();
  }

  void _onWebviewCreated(WebViewController controller) {
    setState(() {
      _controller = controller;
    });
  }

  void _onPageFinishedLoading(BuildContext context, String portalUrl) {
    context.read<PortalWebViewCubit>().notifyWebviewLoaded(portalUrl);
  }

  void _onPageLoadError(BuildContext context) {
    context.read<PortalWebViewCubit>().notifyWebviewHadError();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          NavigationControls(_controller),
        ],
      ),
      body: BlocProvider<PortalWebViewCubit>(
        create: (_) => PortalWebViewCubit(widget.portalPage),
        child: BlocBuilder<PortalWebViewCubit, PortalWebViewState>(
          builder: (context, state) {
            if (state is LoadPortalUrlError || state is LoadWebviewError) {
              return Warning(
                description: Text(context.msg.webview.error.description),
                icon: const Icon(VialerSans.exclamationMark),
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
            if (state is LoadedPortalUrl) {
              return Stack(
                children: [
                  WebView(
                    initialUrl: state.portalUrl,
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: _onWebviewCreated,
                    onPageFinished: (_) => _onPageFinishedLoading(
                      context,
                      state.portalUrl,
                    ),
                    onWebResourceError: (_) => _onPageLoadError(context),
                    gestureNavigationEnabled: true,
                  ),
                  if (state is! LoadedWebview)
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
