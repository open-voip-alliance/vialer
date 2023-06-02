import 'package:meta/meta.dart';

@immutable
class AudioCodec {
  const AudioCodec(this.value);

  factory AudioCodec.fromJson(dynamic json) => AudioCodec(json as String);

  final String value;

  static const opus = AudioCodec('opus');

  static String toJson(AudioCodec codec) => codec.value;

  @override
  bool operator ==(Object other) => other is AudioCodec && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
