import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class PortalWebViewState extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadingPortalUrl extends PortalWebViewState {}

class LoadedPortalUrl extends PortalWebViewState {
  final String portalUrl;

  LoadedPortalUrl({@required this.portalUrl});

  @override
  List<Object> get props => [portalUrl];
}

class LoadedWebview extends LoadedPortalUrl {
  LoadedWebview({@required String portalUrl}) : super(portalUrl: portalUrl);
}

class LoadPortalUrlError extends PortalWebViewState {}

class LoadWebviewError extends PortalWebViewState {}
