import 'package:meta/meta.dart';

@immutable
class AudioCodec {
  final String value;

  const AudioCodec(this.value);

  static const opus = AudioCodec('opus');

  static String toJson(AudioCodec codec) => codec.value;

  static AudioCodec fromJson(dynamic json) => AudioCodec(json as String);

  @override
  bool operator ==(Object other) => other is AudioCodec && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
