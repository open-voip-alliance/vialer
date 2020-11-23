import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../domain/entities/contact.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../util/stylized_snack_bar.dart';
import '../../widgets/caller.dart';
import '../../widgets/header.dart';
import '../widgets/avatar.dart';
import '../widgets/subtitle.dart';
import 'cubit.dart';

const _horizontalPadding = 24.0;
const _leadingSize = 48.0;

class ContactDetailsPage extends StatelessWidget {
  final Contact contact;

  ContactDetailsPage({
    Key key,
    @required this.contact,
  }) : super(key: key);

  void _showSnackBar(BuildContext context) {
    showSnackBar(
      context,
      icon: const Icon(VialerSans.exclamationMark),
      label: Text(context.msg.main.contacts.snackBar.noPermission),
      padding: const EdgeInsets.only(right: 72),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Header(context.msg.main.contacts.title),
        centerTitle: false,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      ),
      body: BlocProvider<ContactDetailsCubit>(
        create: (context) => ContactDetailsCubit(context.read<CallerCubit>()),
        child: Builder(
          builder: (context) {
            final cubit = context.watch<ContactDetailsCubit>();

            return SafeArea(
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
                        builder: (context, state) {
                          void onTapNumber(String n) {
                            return (state is CanCall ||
                                    (state is NoPermission &&
                                        !state.dontAskAgain))
                                ? cubit.call(n)
                                : _showSnackBar(context);
                          }

                          return _DestinationsList(
                            contact: contact,
                            onTapNumber: onTapNumber,
                            onTapEmail: cubit.mail,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DestinationsList extends StatelessWidget {
  final Contact contact;

  final ValueChanged<String> onTapNumber;
  final ValueChanged<String> onTapEmail;

  const _DestinationsList({
    Key key,
    @required this.contact,
    this.onTapNumber,
    this.onTapEmail,
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

  final VoidCallback onTap;

  const _Item({
    Key key,
    @required this.value,
    @required this.label,
    @required this.isEmail,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final label = toBeginningOfSentenceCase(
      this.label,
      VialerLocalizations.of(context).locale.languageCode,
    );

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
