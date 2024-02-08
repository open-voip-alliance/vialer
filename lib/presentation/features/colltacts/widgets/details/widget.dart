import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../../../data/models/colltacts/colltact.dart';
import '../../../../shared/widgets/caller.dart';
import '../../../../util/stylized_snack_bar.dart';
import '../../../../util/widgets_binding_observer_registrar.dart';
import '../../../call/widgets/outgoing_number_prompt/show_prompt.dart';
import '../../controllers/colltact_list/details/cubit.dart';
import '../../controllers/contacts/cubit.dart';
import '../../controllers/shared_contacts/cubit.dart';
import '../colltact_list/details/widget.dart';
import '../edit_shared_contact/page.dart';

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
      sharedContact: (_) => null,
    );

    if (contactId == null) return;

    final contact = state.contacts.firstWhereOrNull(
      (contact) => contact.identifier == contactId,
    );

    if (contact == null) {
      Navigator.pop(context, true);
    }
  }

  void refreshSharedContacts(SharedContactsCubit cubit) =>
      cubit.loadSharedContacts(fullRefresh: true);

  void _onEditTap(
    Colltact colltact,
    ColltactDetailsCubit colltactDetailsCubit,
    SharedContactsCubit sharedContactsCubit,
  ) {
    if (colltact is ColltactContact)
      unawaited(colltactDetailsCubit.edit(colltact));
    else if (colltact is ColltactSharedContact)
      unawaited(
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return EditSharedContactPage(
                sharedContact: colltact.contact,
                onSave: () => refreshSharedContacts(sharedContactsCubit),
                onDelete: () {
                  refreshSharedContacts(sharedContactsCubit);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext _) {
    return BlocListener<CallerCubit, CallerState>(
      listener: _onCallerStateChanged,
      child: BlocProvider<ColltactDetailsCubit>(
        create: (_) => ColltactDetailsCubit(context.read<CallerCubit>()),
        child: BlocConsumer<ContactsCubit, ContactsState>(
          listener: _automaticallyCloseIfContactNoLongerExists,
          builder: (context, state) {
            return BlocProvider<ColltactDetailsCubit>(
              create: (_) => ColltactDetailsCubit(context.watch<CallerCubit>()),
              child: BlocBuilder<SharedContactsCubit, SharedContactsState>(
                builder: (context, sharedContactsState) {
                  final colltactDetailsCubit =
                      context.read<ColltactDetailsCubit>();
                  final sharedContactsCubit =
                      context.read<SharedContactsCubit>();

                  /// Ensure we have the latest sharedContact data
                  var colltact = sharedContactsCubit
                      .refreshColltactSharedContact(widget.colltact);

                  return ColltactDetails(
                    colltact: colltact,
                    onPhoneNumberPressed: (destination) =>
                        showOutgoingNumberPrompt(
                      context,
                      destination,
                      (_) => unawaited(
                        colltactDetailsCubit.call(
                          destination,
                          origin: switch (colltact) {
                            ColltactColleague() => CallOrigin.colleagues,
                            ColltactContact() => CallOrigin.contacts,
                            ColltactSharedContact() =>
                              CallOrigin.sharedContacts,
                          },
                        ),
                      ),
                    ),
                    onEmailPressed: colltactDetailsCubit.mail,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: GestureDetector(
                          onTap: () => _onEditTap(
                            colltact,
                            colltactDetailsCubit,
                            sharedContactsCubit,
                          ),
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
                              : Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: const FaIcon(FontAwesomeIcons.pen),
                                ),
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
