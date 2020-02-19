import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:provider/provider.dart';
import 'package:vialer_lite/device/repositories/call_permission_repository.dart';

import 'controller.dart';
import 'widgets/background.dart';

class OnboardingPage extends View {
  @override
  State<StatefulWidget> createState() => _OnboardingPageState();
}

class _OnboardingPageState
    extends ViewState<OnboardingPage, OnboardingController> {
  _OnboardingPageState()
      : super(OnboardingController(DeviceCallPermissionRepository()));

  @override
  Widget buildPage() {
    return Background(
      child: Scaffold(
        key: globalKey,
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: WillPopScope(
          onWillPop: controller.backward,
          child: DefaultTextStyle(
            style: TextStyle(color: Colors.white),
            child: IconTheme(
              data: IconThemeData(color: Colors.white),
              child: PageView(
                controller: controller.pageController,
                children: controller.pages.map((page) {
                  return SafeArea(
                    child: Provider<EdgeInsets>(
                      create: (_) => EdgeInsets.all(48).copyWith(
                        top: 128,
                        bottom: 32,
                      ),
                      child: page(context),
                    ),
                  );
                }).toList(),
                physics: NeverScrollableScrollPhysics(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
