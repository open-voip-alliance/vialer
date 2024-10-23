import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';

/// Generates `vialer_info.vialer.dart` a file containing version information
/// about Flutter and the voip libraries. This is all generated at build time.
class VersionInfoBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => const {
        r'$lib$': ['version_info.vialer.dart'],
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final content = '''
// GENERATED CODE - DO NOT MODIFY BY HAND

class VialerVersionInfo {
  final String flutter;
  final String dart;
  final String flutterPhoneLib;
  final String androidPhoneLib;
  final String iOSPhoneLib;

  const VialerVersionInfo({
    required this.flutter,
    required this.dart,
    required this.flutterPhoneLib,
    required this.androidPhoneLib,
    required this.iOSPhoneLib,
  });
}

/// The current version information for Vialer, this was generated at build
/// time. If it out of date, re-run the build runner.
///
/// As this is generated at build time you will have versions for both Android
/// Phone Lib and iOS Phone Lib, even if they are not used in the current
/// platform.
const vialerVersionInfo = VialerVersionInfo(
  flutter: '${await _getFlutterVersion()}',
  dart: '${await _getDartVersion()}',
  flutterPhoneLib: '${await _getFlutterPhoneLibVersion()}',
  androidPhoneLib: '${await _getAndroidPhoneLibVersion()}',
  iOSPhoneLib: '${await _getIOSPhoneLibVersion()}',  
);

''';

    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, buildExtensions.buildPath),
      content,
    );
  }

  Future<String> _getFlutterVersion() async {
    final result = await Process.run('flutter', ['--version']);
    if (result.exitCode != 0) return _noVersionFound;
    return RegExp(r'Flutter (\d+\.\d+\.\d+)')
            .firstMatch(result.stdout.toString())
            ?.group(1) ??
        _noVersionFound;
  }

  Future<String> _getDartVersion() async {
    final result = await Process.run('dart', ['--version']);
    if (result.exitCode != 0) return _noVersionFound;
    return RegExp(r'Dart SDK version: (\d+\.\d+\.\d+)')
            .firstMatch(result.stdout.toString())
            ?.group(1) ??
        _noVersionFound;
  }

  Future<String> _getFlutterPhoneLibVersion() async {
    final file = File('pubspec.lock');

    if (!file.existsSync()) return _noVersionFound;

    bool foundEntry = false;
    for (final line in await file.readAsLines()) {
      if (line.contains('flutter_phone_lib:')) {
        foundEntry = true;
      }
      if (foundEntry && line.trim().startsWith('version:')) {
        return line.split(':').last.trim().replaceAll('"', '');
      }
    }

    return _noVersionFound;
  }

  Future<String> _getAndroidPhoneLibVersion() async {
    final file = await _findNativeDependencyFile('android/build.gradle');
    if (!file.existsSync()) return _noVersionFound;
    return RegExp(r'Android-Phone-Integration-Lib:(\d+\.\d+\.\d+)')
            .firstMatch(await file.readAsStringSync())
            ?.group(1) ??
        _noVersionFound;
  }

  Future<String> _getIOSPhoneLibVersion() async {
    final file = await _findNativeDependencyFile('ios/Podfile');
    if (!file.existsSync()) return _noVersionFound;
    final regex = RegExp(r"pod\s*'iOSPhoneLib',\s*'(\d+\.\d+\.\d+)'");
    final match = regex.firstMatch(await file.readAsString());
    if (match == null) return _noVersionFound;
    final version = await match.group(1);
    return version ?? _noVersionFound;
  }

  Future<File> _findNativeDependencyFile(String path) async {
    final fpl = await _getFlutterPhoneLibVersion();

    // We can use the symlink locally but this doesn't show up in Codemagic
    // so we will use the direct path in that case. This can't be done locally
    // because it requires elevated permissions.
    final baseUrl = _isCI
        ? '/Users/builder/.pub-cache/hosted/pub.dev/flutter_phone_lib-$fpl'
        : 'ios/.symlinks/plugins/flutter_phone_lib';

    return File('$baseUrl/$path');
  }
}

const _noVersionFound = 'No version found';

bool get _isCI => Platform.environment['CI']?.toLowerCase() == 'true';

extension on Map<String, List<String>> {
  /// Generates the build path for this builder, this only works when it is
  /// a simple one file builder so having multiple values in this array will
  /// throw an error.
  String get buildPath {
    if (values.length != 1 || keys.length != 1) {
      throw StateError('Only simple 1-1 build paths are supported.');
    }

    return '${keys.first.replaceAll('\$', '')}/${values.first.first}';
  }
}
