import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../domain/entities/t9_contact.dart';

import '../../../contacts/widgets/avatar.dart';

import 'bloc.dart';

class T9ContactsListView extends StatefulWidget {
  final TextEditingController controller;

  const T9ContactsListView({Key key, @required this.controller})
      : super(key: key);

  @override
  _T9ContactsListViewState createState() => _T9ContactsListViewState();
}

class _T9ContactsListViewState extends State<T9ContactsListView> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: BlocProvider<T9ContactsBloc>(
        create: (_) => T9ContactsBloc(),
        child: BlocBuilder<T9ContactsBloc, T9ContactsState>(
          builder: (context, state) {
            final contacts = state is ContactsLoaded
                ? state.filteredContacts
                : <T9Contact>[];

            return _T9ContactsList(
              contacts: contacts,
              controller: widget.controller,
            );
          },
        ),
      ),
    );
  }
}

class _T9ContactsList extends StatefulWidget {
  final List<T9Contact> contacts;
  final TextEditingController controller;

  const _T9ContactsList({Key key, this.contacts, this.controller})
      : super(key: key);

  @override
  _T9ContactsListState createState() => _T9ContactsListState();
}

class _T9ContactsListState extends State<_T9ContactsList> {
  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_handleStatusChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleStatusChange);

    super.dispose();
  }

  void _handleStatusChange() {
    context
        .read<T9ContactsBloc>()
        .add(FilterT9Contacts(widget.controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: widget.contacts.length,
      itemBuilder: (context, index) {
        final contact = widget.contacts[index];

        return ListTile(
          leading: ContactAvatar(contact),
          title: Text(contact.name),
          subtitle: Text(contact.relevantPhoneNumber.value),
          onTap: () =>
              widget.controller.text = contact.relevantPhoneNumber.value,
        );
      },
    );
  }
}
