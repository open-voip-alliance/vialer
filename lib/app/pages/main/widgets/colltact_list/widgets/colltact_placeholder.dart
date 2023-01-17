import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../resources/localizations.dart';
import '../../../../../util/brand.dart';
import '../../../../../util/conditional_capitalization.dart';
import '../../../../../widgets/stylized_button.dart';
import '../../conditional_placeholder.dart';
import '../cubit.dart';

class ColltactsPlaceholder extends StatelessWidget {
  const ColltactsPlaceholder({
    Key? key,
    required this.cubit,
    required this.state,
  }) : super(key: key);

  final ColltactsCubit cubit;
  final ColltactsState state;

  @override
  Widget build(BuildContext context) {
    final state = this.state;

    final appName = context.brand.appName;

    return SingleChildScrollView(
      child: state is ColltactsLoaded && state.noContactPermission
          ? Warning(
              icon: const FaIcon(FontAwesomeIcons.lock),
              title: Text(
                context.msg.main.contacts.list.noPermission.title(appName),
              ),
              description: !state.dontAskAgain
                  ? Text(
                      context.msg.main.contacts.list.noPermission
                          .description(appName),
                    )
                  : Text(
                      context.msg.main.contacts.list.noPermission
                          .permanentDescription(appName),
                    ),
              children: <Widget>[
                const SizedBox(height: 40),
                StylizedButton.raised(
                  colored: true,
                  onPressed: !state.dontAskAgain
                      ? cubit.requestPermission
                      : cubit.openAppSettings,
                  child: !state.dontAskAgain
                      ? Text(
                          context.msg.main.contacts.list.noPermission
                              .buttonPermission
                              .toUpperCaseIfAndroid(context),
                        )
                      : Text(
                          context.msg.main.contacts.list.noPermission
                              .buttonOpenSettings
                              .toUpperCaseIfAndroid(context),
                        ),
                ),
              ],
            )
          : state is LoadingColltacts
              ? LoadingIndicator(
                  title: Text(
                    context.msg.main.contacts.list.loading.title,
                  ),
                  description: Text(
                    context.msg.main.contacts.list.loading.description,
                  ),
                )
              : Warning(
                  icon: const FaIcon(FontAwesomeIcons.userSlash),
                  title: Text(
                    context.msg.main.contacts.list.empty.title,
                  ),
                  description: Text(
                    context.msg.main.contacts.list.empty.description(
                      context.brand.appName,
                    ),
                  ),
                ),
    );
  }
}
