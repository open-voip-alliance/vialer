import 'dart:async';

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
  const ColltactPageDetails({
    required this.colltact,
    super.key,
  });

  final Colltact colltact;

  @override
  State<ColltactPageDetails> createState() => _ColltactPageDetailsState();
}

class _ColltactPageDetailsState extends State<ColltactPageDetails>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {
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

  /// If the user has deleted the contact that relates to this details page,
  /// we want to close it rather than showing outdated information.
  ///
  /// Because of the way we import contacts in the background, this will
  /// likely not trigger immediately, especially for users with a lot of
  /// contacts.
  void _automaticallyCloseIfContactNoLongerExists(
    BuildContext context,
    ContactsState state,
  ) {
    if (state is! ContactsLoaded || state.contacts.isEmpty) return;

    final contactId = widget.colltact.when(
      colleague: (colleague) => null,
      contact: (contact) => contact.identifier,
    );

    if (contactId == null) return;

    final contact = state.contacts.firstWhereOrNull(
      (contact) => contact.identifier == contactId,
    );

    if (contact == null) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallerCubit, CallerState>(
      listener: _onCallerStateChanged,
      child: BlocProvider<ColltactDetailsCubit>(
        create: (_) => ColltactDetailsCubit(context.read<CallerCubit>()),
        child: BlocConsumer<ContactsCubit, ContactsState>(
          listener: _automaticallyCloseIfContactNoLongerExists,
          builder: (context, state) {
            return BlocProvider<ColltactDetailsCubit>(
              create: (_) => ColltactDetailsCubit(context.watch<CallerCubit>()),
              child: Builder(
                builder: (context) {
                  final cubit = context.read<ColltactDetailsCubit>();

                  return ColltactDetails(
                    colltact: widget.colltact,
                    onPhoneNumberPressed: (destination) => unawaited(
                      cubit.call(
                        destination,
                        origin: widget.colltact.map(
                          colleague: (_) => CallOrigin.colleagues,
                          contact: (_) => CallOrigin.contacts,
                        ),
                      ),
                    ),
                    onEmailPressed: cubit.mail,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: GestureDetector(
                          onTap: () => unawaited(cubit.edit(widget.colltact)),
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
