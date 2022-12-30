import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../../../data/models/colltact.dart';
import '../../../../../../domain/colltacts/contact.dart';
import '../../../../../resources/localizations.dart';
import '../../../widgets/caller.dart';
import '../../../widgets/header.dart';
import '../cubit.dart' hide NoPermission;
import '../widgets/avatar.dart';
import '../widgets/subtitle.dart';
import 'cubit.dart';

const _horizontalPadding = 24.0;
const _leadingSize = 48.0;

class ColltactDetails extends StatefulWidget {
  final Colltact colltact;
  final void Function(String) onPhoneNumberPressed;
  final void Function(String) onEmailPressed;
  final List<Widget> actions;

  const ColltactDetails({
    Key? key,
    required this.colltact,
    required this.onPhoneNumberPressed,
    required this.onEmailPressed,
    this.actions = const [],
  }) : super(key: key);

  @override
  _ColltactDetailsState createState() => _ColltactDetailsState();
}

class _ColltactDetailsState extends State<ColltactDetails> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ColltactDetailsCubit>(
      create: (_) => ColltactDetailsCubit(context.read<CallerCubit>()),
      child: BlocBuilder<ColltactsCubit, ColltactsState>(
        builder: (context, state) {
          var colltact = widget.colltact;

          if (state is ColltactsLoaded) {
            colltact = state.colltacts.firstWhere(
              (colltact) => colltact.when(
                contact: (contact) =>
                    contact.identifier ==
                    (widget.colltact as ColltactContact).contact.identifier,
                colleague: (colleague) => false, //wip
              ),
              orElse: () => widget.colltact,
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
                          //wip
                          ColltactAvatar(colltact, size: _leadingSize),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                colltact.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ColltactSubtitle(colltact),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => context
                            .read<ColltactsCubit>()
                            .reloadContacts(), //wip
                        child: _DestinationsList(
                          //wip until _DestinationsList accepts Colltact
                          contact: (colltact as ColltactContact).contact,
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
  //wip
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
