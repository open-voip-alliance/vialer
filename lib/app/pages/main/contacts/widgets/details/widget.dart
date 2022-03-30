import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../domain/entities/contact.dart';
import '../../../../../resources/localizations.dart';
import '../../../../../resources/theme.dart';
import '../../../../../util/widgets_binding_observer_registrar.dart';
import '../../../util/stylized_snack_bar.dart';
import '../../../widgets/caller.dart';
import '../../../widgets/contact_list/cubit.dart' hide NoPermission;
import '../../../widgets/contact_list/details/cubit.dart';
import '../../../widgets/contact_list/details/widget.dart';

class ContactPageDetails extends StatefulWidget {
  final Contact contact;

  const ContactPageDetails({
    Key? key,
    required this.contact,
  }) : super(key: key);

  @override
  _ContactPageDetailsState createState() => _ContactPageDetailsState();
}

class _ContactPageDetailsState extends State<ContactPageDetails>
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
      icon: const Icon(VialerSans.exclamationMark),
      label: Text(context.msg.main.contacts.snackBar.noPermission),
      padding: const EdgeInsets.only(right: 72),
    );
  }

  void _onCallerStateChanged(BuildContext context, CallerState state) {
    if (state is NoPermission) {
      _showSnackBar(context);
    }
  }

  void _onStateChanged(BuildContext context, ContactsState state) {
    if (state is ContactsLoaded) {
      final contact = state.contacts.firstWhereOrNull(
        (contact) => contact.identifier == widget.contact.identifier,
      );
      if (contact == null && _madeEdit) {
        // Contact doesn't exist anymore after returning back to the app,
        // it's probably deleted, so close this detail screen.
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallerCubit, CallerState>(
      listener: _onCallerStateChanged,
      child: BlocProvider<ContactDetailsCubit>(
        create: (_) => ContactDetailsCubit(context.read<CallerCubit>()),
        child: BlocConsumer<ContactsCubit, ContactsState>(
          listener: _onStateChanged,
          builder: (context, state) {
            return BlocProvider<ContactDetailsCubit>(
              create: (_) => ContactDetailsCubit(context.watch<CallerCubit>()),
              child: Builder(
                builder: (context) {
                  final cubit = context.read<ContactDetailsCubit>();

                  return ContactDetails(
                    contact: widget.contact,
                    onPhoneNumberPressed: cubit.call,
                    onEmailPressed: cubit.mail,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: GestureDetector(
                          onTap: () => cubit.edit(widget.contact),
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
                              : const Icon(Icons.edit),
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
