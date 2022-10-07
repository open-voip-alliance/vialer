import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/entities/temporary_redirect.dart';
import '../../../../resources/localizations.dart';
import '../../../../util/conditional_capitalization.dart';
import '../../../../widgets/stylized_button.dart';
import '../../../../widgets/stylized_dropdown.dart';
import 'cubit.dart';

class TemporaryRedirectPicker extends StatelessWidget {
  final VoidCallback? onCancel;

  const TemporaryRedirectPicker({
    super.key,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TemporaryRedirectPickerCubit>(
      create: (_) => TemporaryRedirectPickerCubit(),
      child: BlocBuilder<TemporaryRedirectPickerCubit,
          TemporaryRedirectPickerState>(
        builder: (context, state) {
          if (state is LoadingDestinations) {
            return const CircularProgressIndicator();
          }

          final cubit = context.watch<TemporaryRedirectPickerCubit>();

          state as LoadedDestinations;

          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: context
                            .msg.main.temporaryRedirect.explanation.start,
                      ),
                      TextSpan(
                        text: state.currentDestination.name,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      TextSpan(
                        text:
                            context.msg.main.temporaryRedirect.explanation.end,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.msg.main.temporaryRedirect.dropdownTitle,
                ),
                const SizedBox(height: 8),
                StylizedDropdown<TemporaryRedirectDestination>(
                  isExpanded: true,
                  value: state.currentDestination,
                  items: state.availableDestinations.map(
                    (dest) {
                      return DropdownMenuItem<TemporaryRedirectDestination>(
                        value: dest,
                        child: Text(dest.name),
                      );
                    },
                  ).toList(),
                  onChanged: (dest) => cubit.changeCurrentDestination(dest!),
                ),
                const SizedBox(height: 16),
                StylizedButton.raised(
                  colored: true,
                  onPressed: cubit.startRedirect,
                  child: Text(
                    context.msg.main.temporaryRedirect.actions.startRedirect
                        .toUpperCaseIfAndroid(context),
                  ),
                ),
                if (onCancel != null) ...[
                  const SizedBox(height: 12),
                  StylizedButton.outline(
                    colored: true,
                    onPressed: onCancel,
                    child: Text(
                      context.msg.main.temporaryRedirect.actions.cancel
                          .toUpperCaseIfAndroid(context),
                    ),
                  )
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}
