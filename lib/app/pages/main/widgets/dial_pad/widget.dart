import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../resources/theme.dart';
import '../../../../widgets/connectivity_checker.dart';
import 'key_input.dart';
import 'keypad.dart';

class DialPad extends StatelessWidget {
  final TextEditingController controller;

  /// Whether input can be deleted with the delete button. If false, the
  /// delete button will stay greyed-out, even if input is present.
  final bool canDelete;

  /// Called when the delete button has been long-pressed, and all input is
  /// deleted.
  final VoidCallback? onDeleteAll;

  final Widget primaryButton;
  final Widget? secondaryButton;

  const DialPad({
    Key? key,
    required this.controller,
    this.onDeleteAll,
    this.canDelete = true,
    required this.primaryButton,
    this.secondaryButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          child: KeyInput(
            controller: controller,
          ),
        ),
        if (context.isIOS) const SizedBox(height: 24),
        Flexible(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child:
                      BlocBuilder<ConnectivityCheckerCubit, ConnectivityState>(
                    builder: (context, state) {
                      return Keypad(
                        controller: controller,
                        constraints: constraints,
                        canDelete: canDelete,
                        primaryButton: primaryButton,
                        secondaryButton: secondaryButton,
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
