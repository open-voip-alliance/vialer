import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../data/models/colltact.dart';
import '../../../../../resources/localizations.dart';
import '../../../../../resources/theme.dart';
import '../../../../../util/widgets_binding_observer_registrar.dart';
import '../../../util/stylized_snack_bar.dart';
import '../../../widgets/caller.dart';
import '../../../widgets/colltact_list/cubit.dart';
import '../../../widgets/colltact_list/details/cubit.dart';
import '../../../widgets/colltact_list/details/widget.dart';

class ColltactPageDetails extends StatefulWidget {
  final Colltact colltact;

  const ColltactPageDetails({
    Key? key,
    required this.colltact,
  }) : super(key: key);

  @override
  _ColltactPageDetailsState createState() => _ColltactPageDetailsState();
}

class _ColltactPageDetailsState extends State<ColltactPageDetails>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {
  bool _madeEdit = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive) {
      _madeEdit = true;
    }
  }

  void _showSnackBar(BuildContext context) {
    showSnackBar(
      context,
      icon: const FaIcon(FontAwesomeIcons.exclamation),
      label: Text(context.msg.main.contacts.snackBar.noPermission),
      padding: const EdgeInsets.only(right: 72),
    );
  }

  void _onCallerStateChanged(BuildContext context, CallerState state) {
    if (state is NoPermission) {
      _showSnackBar(context);
    }
  }

  void _onStateChanged(BuildContext context, ColltactsState state) {
    if (state is ColltactsLoaded) {
      final colltactId = widget.colltact.when(
        colleague: (colleague) => colleague.id,
        contact: (contact) => contact.identifier,
      );

      final colltact = state.colltacts.firstWhereOrNull(
        (colltact) => colltact.when(
          contact: (contact) => contact.identifier == colltactId,
          colleague: (colleague) => colleague.id == colltactId,
        ),
      );

      if (colltact == null && _madeEdit) {
        // Colltact doesn't exist anymore after returning back to the app,
        // it's probably deleted, so close this detail screen.
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallerCubit, CallerState>(
      listener: _onCallerStateChanged,
      child: BlocProvider<ColltactDetailsCubit>(
        create: (_) => ColltactDetailsCubit(context.read<CallerCubit>()),
        child: BlocConsumer<ColltactsCubit, ColltactsState>(
          listener: _onStateChanged,
          builder: (context, state) {
            return BlocProvider<ColltactDetailsCubit>(
              create: (_) => ColltactDetailsCubit(context.watch<CallerCubit>()),
              child: Builder(
                builder: (context) {
                  final cubit = context.read<ColltactDetailsCubit>();

                  return ColltactDetails(
                    colltact: widget.colltact,
                    onPhoneNumberPressed: (destination) => cubit.call(
                      destination,
                      origin: widget.colltact.map(
                        colleague: (_) => CallOrigin.colleagues,
                        contact: (_) => CallOrigin.contacts,
                      ),
                    ),
                    onEmailPressed: cubit.mail,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: GestureDetector(
                          onTap: () => cubit.edit(widget.colltact),
                          child: context.isIOS
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 24),
                                  child: Text(
                                    context.msg.main.contacts.edit,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                )
                              : const FaIcon(FontAwesomeIcons.pen),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
