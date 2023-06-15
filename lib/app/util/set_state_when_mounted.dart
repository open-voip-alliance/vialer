import 'package:flutter/widgets.dart';

extension SetStateWhenMounted on State {
  void setStateWhenMounted(VoidCallback fn) {
    if (mounted) {
      // ignore: invalid_use_of_protected_member
      setState(fn);
    }
  }
}
