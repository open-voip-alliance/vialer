import 'package:equatable/equatable.dart';

abstract class WebViewState extends Equatable {
  const WebViewState();

  @override
  List<Object?> get props => [];
}

class LoadingUrl extends WebViewState {}

class LoadedUrl extends WebViewState {
  final String url;

  const LoadedUrl({required this.url});

  @override
  List<Object?> get props => [url];
}

class LoadedWebView extends LoadedUrl {
  const LoadedWebView({required String url}) : super(url: url);
}

class LoadPortalUrlError extends WebViewState {}

class LoadWebViewError extends WebViewState {
  final String description;

  const LoadWebViewError({required this.description});

  @override
  List<Object?> get props => [description];
}
