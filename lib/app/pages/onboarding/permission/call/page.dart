import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:vialer_lite/device/repositories/call_permission_repository.dart';

import '../../widgets/stylized_button.dart';
import '../../../../resources/theme.dart';

import 'controller.dart';

class CallPermissionPage extends View {
  final VoidCallback forward;

  CallPermissionPage(this.forward, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CallPermissionPageState(forward);
}

class _CallPermissionPageState
    extends ViewState<CallPermissionPage, CallPermissionController> {
  _CallPermissionPageState(VoidCallback forward)
      : super(
          CallPermissionController(
            DeviceCallPermissionRepository(),
            forward,
          ),
        );

  @override
  Widget buildPage() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 48,
      ).copyWith(
        bottom: 24,
      ),
      child: Column(
        children: <Widget>[
          SizedBox(height: 64),
          Icon(VialerSans.phone, size: 54),
          SizedBox(height: 24),
          Text(
            'Call permission',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'This permissions is required to make calls seamlessly from'
            'the app using the default call app.',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: StylizedOutlineButton(
                      text: 'Deny',
                      onPressed: () {},
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: StylizedRaisedButton(
                      text: 'Allow',
                      onPressed: controller.ask,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
