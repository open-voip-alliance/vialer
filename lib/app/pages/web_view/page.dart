import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';

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

  static MaterialPageRoute route(WebPage page) => MaterialPageRoute(
        builder: (context) => WebViewPage(page),
      );

  static Future open(BuildContext context, {required WebPage to}) =>
      Navigator.of(context, rootNavigator: true).push(route(to));

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final InAppWebViewGroupOptions _options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      clearCache: true,
      useOnDownloadStart: true,
      transparentBackground: true,
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
      geolocationEnabled: false,
    ),
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

  void _onDownloadStartRequest(
    InAppWebViewController _,
    DownloadStartRequest request,
  ) async {
    final directory = await getApplicationDocumentsDirectory();

    final task = DownloadTask(
      url: request.url.toString(),
      filename: request.suggestedFilename,
      baseDirectory: BaseDirectory.applicationDocuments,
      directory: 'call_recordings',
    );

    final result = await FileDownloader()
        .configureNotification(
          running: TaskNotification('Downloading', 'file: {filename}',),
          complete:
              TaskNotification('Download {filename}', 'Download complete',),
          error: TaskNotification('Download {filename}', 'Download failed',),
          progressBar: true,
        )
        .download(
          task,
          onProgress: (a) => print('Progress: $a'),
          onStatus: (status) => print('Status: $status'),
        );

    await FileDownloader().moveToSharedStorage(task, SharedStorage.downloads);

    print(result);
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
                  InAppWebView(
                    key: Key(state.url),
                    initialUrlRequest: URLRequest(url: Uri.parse(state.url)),
                    initialOptions: _options,
                    onWebViewCreated: _onWebViewCreated,
                    onLoadError: (_, __, code, message) =>
                        _onPageLoadError(context, code, message),
                    onProgressChanged: (_, progress) =>
                        _onProgressChanged(context, progress, state.url),
                    onDownloadStartRequest: _onDownloadStartRequest,
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
