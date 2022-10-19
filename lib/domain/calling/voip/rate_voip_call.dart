import 'dart:core';

import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../../dependency_locator.dart';
import '../../feedback/call_problem.dart';
import '../../metrics/metrics.dart';
import '../../metrics/track_voip_call.dart';
import '../../use_case.dart';
import '../../user/connectivity/connectivity.dart';

class RateVoipCallUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _connectivityRepository = dependencyLocator<ConnectivityRepository>();

  Future<void> call({
    required CallFeedbackResult feedback,
    required Call call,
    required Set<AudioRoute> usedRoutes,
    required double mos,
  }) async {
    final connectivityType = await _connectivityRepository.currentType;
    final audioProblems = feedback.audioProblems ?? [];

    _metricsRepository.track('call-rating', {
      'rating': feedback.rating,
      'mos': mos,
      'duration': call.duration,
      'direction': call.direction.toTrackString(),
      'bluetooth-used': usedRoutes.contains(AudioRoute.bluetooth),
      'phone-used': usedRoutes.contains(AudioRoute.phone),
      'speaker-used': usedRoutes.contains(AudioRoute.speaker),
      'audio-routes': _createAudioRouteString(usedRoutes),
      'connection': connectivityType.toString(),
      'problem': feedback.problem?.toShortString() ?? false,
      ...audioProblems.toShortStringMap(),
    });
  }

  /// Create a string such as phone|bluetooth that will include
  /// the combination of routes used. This is to provide
  /// alternative ways to view the events in a dashboard.
  String _createAudioRouteString(Set<AudioRoute> routes) => [
        if (routes.contains(AudioRoute.phone)) 'phone',
        if (routes.contains(AudioRoute.speaker)) 'speaker',
        if (routes.contains(AudioRoute.bluetooth)) 'bluetooth',
      ].join('|');
}

extension Mapping on List<CallAudioProblem> {
  /// Creates a map from a list of [CallAudioProblem] with the
  /// [CallAudioProblem] as the key and a bool as the value.
  Map<CallAudioProblem, bool> toBoolMap({
    bool defaultValue = false,
  }) =>
      Map<CallAudioProblem, bool>.fromIterable(
        CallAudioProblem.values,
        key: (e) => e as CallAudioProblem,
        value: (e) => defaultValue,
      );

  /// Convert to a map with the key as the short string of
  /// [CallAudioProblem] and the given boolean value.
  Map<String, bool> toShortStringMap({
    bool defaultValue = false,
  }) =>
      toBoolMap(
        defaultValue: defaultValue,
      ).map(
        (key, value) => MapEntry(
          key.toShortString(),
          contains(key),
        ),
      );
}
