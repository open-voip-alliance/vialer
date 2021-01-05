import 'package:json_annotation/json_annotation.dart';

class JsonIdConverter implements JsonConverter<int, String> {
  const JsonIdConverter();

  @override
  int fromJson(String json) => int.parse(json);

  @override
  String toJson(int object) => object.toString();
}
