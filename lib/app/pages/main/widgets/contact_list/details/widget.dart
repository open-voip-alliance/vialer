import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../../../domain/colltacts/contact.dart';
import '../../../../../resources/localizations.dart';
import '../../../../../util/contact.dart';
import '../../../widgets/caller.dart';
import '../../../widgets/header.dart';
import '../cubit.dart' hide NoPermission;
import '../widgets/avatar.dart';
import '../widgets/subtitle.dart';
import 'cubit.dart';

const _horizontalPadding = 24.0;
const _leadingSize = 48.0;

class ContactDetails extends StatefulWidget {
  final Contact contact;
  final void Function(String) onPhoneNumberPressed;
  final void Function(String) onEmailPressed;
  final List<Widget> actions;

  const ContactDetails({
    Key? key,
    required this.contact,
    required this.onPhoneNumberPressed,
    required this.onEmailPressed,
    this.actions = const [],
  }) : super(key: key);

  @override
  _ContactDetailsState createState() => _ContactDetailsState();
}

class _ContactDetailsState extends State<ContactDetails> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ContactDetailsCubit>(
      create: (_) => ContactDetailsCubit(context.read<CallerCubit>()),
      child: BlocBuilder<ContactsCubit, ContactsState>(
        builder: (context, state) {
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
                iconTheme: IconThemeData(
                  color: Theme.of(context).primaryColor,
                ),
                actions: widget.actions),
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
                                contact.displayName,
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
                      child: RefreshIndicator(
                        onRefresh: () =>
                            context.read<ContactsCubit>().reloadContacts(),
                        child: _DestinationsList(
                          contact: contact,
                          onPhoneNumberPressed: widget.onPhoneNumberPressed,
                          onEmailPressed: widget.onEmailPressed,
                        ),
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

  final void Function(String) onPhoneNumberPressed;
  final void Function(String) onEmailPressed;

  const _DestinationsList({
    Key? key,
    required this.contact,
    required this.onPhoneNumberPressed,
    required this.onEmailPressed,
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
              onTap: () => onPhoneNumberPressed.call(p.value),
            ),
          )
          .followedBy(
            contact.emails.map(
              (e) => _Item(
                value: e.value,
                label: e.label,
                isEmail: true,
                onTap: () => onEmailPressed.call(e.value),
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
        child: FaIcon(
          isEmail ? FontAwesomeIcons.envelope : FontAwesomeIcons.phone,
        ),
      ),
      title: Text(value),
      subtitle: Text(label),
      onTap: onTap,
    );
  }
}
