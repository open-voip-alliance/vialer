import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

@freezed
sealed class WebViewState with _$WebViewState {
  const factory WebViewState.loadingUrl() = LoadingUrl;
  const factory WebViewState.loadedUrl({
    required String url,
  }) = LoadedUrl;
  const factory WebViewState.loadedWebView({
    required String url,
  }) = LoadedWebView;
  const factory WebViewState.loadPortalUrlError() = LoadPortalUrlError;
  const factory WebViewState.loadWebViewError({
    required String description,
  }) = LoadWebViewError;
}
