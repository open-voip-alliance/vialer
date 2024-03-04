import 'package:vialer/presentation/util/pigeon.dart';

class _NativeToFlutterListener implements NativeToFlutter {
  final void Function(String) onLaunchDialerAndPopulateNumber;

  _NativeToFlutterListener({required this.onLaunchDialerAndPopulateNumber});

  @override
  void launchDialerAndPopulateNumber(String number) =>
      onLaunchDialerAndPopulateNumber(number);
}

extension NativeToFlutterSetup on NativeToFlutter {
  static void onLaunchDialerAndPopulateNumber(void Function(String) callback) =>
      NativeToFlutter.setup(
        _NativeToFlutterListener(onLaunchDialerAndPopulateNumber: callback),
      );
}
