import 'package:flutter/widgets.dart';

extension TextExtension on Text {
  Text capitalize() {
    return Text('${data[0].toUpperCase()}${data.substring(1)}');
  }
}
