import 'package:flutter/material.dart';

// TODO: Once Dart mixins are more powerful, also mixin WidgetsBindingObserver
// here, so classes don't have to mixin WidgetsBindingObserver _and_ this mixin.
mixin WidgetsBindingObserverRegistrar<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
