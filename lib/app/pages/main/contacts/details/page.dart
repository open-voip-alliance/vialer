import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../domain/entities/contact.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/widgets_binding_observer_registrar.dart';
import '../../util/stylized_snack_bar.dart';
import '../../widgets/caller.dart';
import '../../widgets/header.dart';
import '../cubit.dart' hide NoPermission;
import '../widgets/avatar.dart';
import '../widgets/subtitle.dart';
import 'cubit.dart';

const _horizontalPadding = 24.0;
const _leadingSize = 48.0;

class ContactDetailsPage extends StatefulWidget {
  final Contact contact;

  const ContactDetailsPage({
    Key? key,
    required this.contact,
  }) : super(key: key);

  @override
  _ContactDetailsPageState createState() => _ContactDetailsPageState();
}

class _ContactDetailsPageState extends State<ContactDetailsPage>
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
    return BlocProvider<ContactDetailsCubit>(
      create: (_) => ContactDetailsCubit(context.read<CallerCubit>()),
      child: BlocConsumer<ContactsCubit, ContactsState>(
        listener: _onStateChanged,
        builder: (context, state) {
          final cubit = context.watch<ContactDetailsCubit>();

          var contact = widget.contact;

          if (state is ContactsLoaded) {
            contact = state.contacts.firstWhere(
              (contact) => contact.identifier == widget.contact.identifier,
              orElse: () => widget.contact,
            );
          }

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Header(context.msg.main.contacts.title),
              centerTitle: false,
              iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: () => cubit.edit(contact),
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
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 32,
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _horizontalPadding,
                      ),
                      child: Row(
                        children: <Widget>[
                          ContactAvatar(contact, size: _leadingSize),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                contact.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ContactSubtitle(contact),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: BlocBuilder<CallerCubit, CallerState>(
                        builder: (context, callerState) {
                          void onTapNumber(String n) {
                            return (callerState is CanCall ||
                                    (callerState is NoPermission &&
                                        !callerState.dontAskAgain))
                                ? cubit.call(n)
                                : _showSnackBar(context);
                          }

                          return RefreshIndicator(
                            onRefresh: () =>
                                context.read<ContactsCubit>().reloadContacts(),
                            child: _DestinationsList(
                              contact: contact,
                              onTapNumber: onTapNumber,
                              onTapEmail: cubit.mail,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DestinationsList extends StatelessWidget {
  final Contact contact;

  final ValueChanged<String> onTapNumber;
  final ValueChanged<String> onTapEmail;

  const _DestinationsList({
    Key? key,
    required this.contact,
    required this.onTapNumber,
    required this.onTapEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: contact.phoneNumbers
          .map(
            (p) => _Item(
              value: p.value,
              label: p.label,
              isEmail: false,
              onTap: () => onTapNumber(p.value),
            ),
          )
          .followedBy(
            contact.emails.map(
              (e) => _Item(
                value: e.value,
                label: e.label,
                isEmail: true,
                onTap: () => onTapEmail(e.value),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Item extends StatelessWidget {
  final String value;
  final String label;

  final bool isEmail;

  final VoidCallback? onTap;

  const _Item({
    Key? key,
    required this.value,
    required this.label,
    required this.isEmail,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final label = toBeginningOfSentenceCase(
      this.label,
      VialerLocalizations.of(context).locale.languageCode,
    )!;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
      ),
      leading: Container(
        width: _leadingSize,
        alignment: Alignment.center,
        child: Icon(isEmail ? VialerSans.mail : VialerSans.phone),
      ),
      title: Text(value),
      subtitle: Text(label),
      onTap: onTap,
    );
  }
}
