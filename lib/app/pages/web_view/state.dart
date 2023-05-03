import 'package:equatable/equatable.dart';

abstract class WebViewState extends Equatable {
  const WebViewState();

  @override
  List<Object?> get props => [];
}

class LoadingUrl extends WebViewState {}

class LoadedUrl extends WebViewState {
  const LoadedUrl({required this.url});

  final String url;

  @override
  List<Object?> get props => [url];
}

class LoadedWebView extends LoadedUrl {
  const LoadedWebView({required super.url});
}

class LoadPortalUrlError extends WebViewState {}

class LoadWebViewError extends WebViewState {
  const LoadWebViewError({required this.description});

  final String description;

  @override
  List<Object?> get props => [description];
}
