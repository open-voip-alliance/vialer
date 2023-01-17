import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../../../data/models/colltact.dart';
import '../../../../../resources/localizations.dart';
import '../../../widgets/caller.dart';
import '../../../widgets/header.dart';
import '../cubit.dart';
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
                contact: (contact) => widget.colltact is ColltactContact
                    ? contact.identifier ==
                        (widget.colltact as ColltactContact).contact.identifier
                    : false,
                colleague: (colleague) => widget.colltact is ColltactColleague
                    ? colleague.id ==
                        (widget.colltact as ColltactColleague).colleague.id
                    : false,
              ),
              orElse: () => colltact,
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
              actions: colltact.when(
                colleague: (_) => null,
                contact: (_) => widget.actions,
              ),
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
                              colltact.when(
                                colleague: (_) => const SizedBox.shrink(),
                                contact: (contact) =>
                                    ColltactSubtitle(colltact),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () =>
                            context.read<ColltactsCubit>().reloadColltacts(),
                        child: _DestinationsList(
                          colltact: colltact,
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
  final Colltact colltact;

  final void Function(String) onPhoneNumberPressed;
  final void Function(String) onEmailPressed;

  const _DestinationsList({
    Key? key,
    required this.colltact,
    required this.onPhoneNumberPressed,
    required this.onEmailPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: colltact.when(
        colleague: (colleague) => [
          if (colleague.number != null)
            _Item(
              value: colleague.number!,
              isEmail: false,
              onTap: () => onPhoneNumberPressed.call(colleague.number!),
            ),
        ],
        contact: (contact) => contact.phoneNumbers
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
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String value;
  final String? label;

  final bool isEmail;

  final VoidCallback? onTap;

  const _Item({
    Key? key,
    required this.value,
    this.label,
    required this.isEmail,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final label = this.label != null
        ? toBeginningOfSentenceCase(
            this.label,
            VialerLocalizations.of(context).locale.languageCode,
          )
        : null;

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
      subtitle: label == null ? null : Text(label),
      onTap: onTap,
    );
  }
}