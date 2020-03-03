import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:provider/provider.dart';

import '../../../domain/repositories/permission.dart';

import 'controller.dart';
import 'widgets/background.dart';

class OnboardingPage extends View {
  final PermissionRepository _permissionRepository;

  OnboardingPage(this._permissionRepository);

  @override
  State<StatefulWidget> createState() =>
      _OnboardingPageState(_permissionRepository);
}

class _OnboardingPageState
    extends ViewState<OnboardingPage, OnboardingController> {
  _OnboardingPageState(PermissionRepository permissionRepository)
      : super(OnboardingController(permissionRepository));

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
