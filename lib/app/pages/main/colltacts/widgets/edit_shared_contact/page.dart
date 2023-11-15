import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../domain/colltacts/shared_contacts/shared_contact.dart';
import '../../../../../resources/localizations.dart';
import '../shared_contact_form/cubit.dart';
import '../shared_contact_form/widget.dart';

class EditSharedContactPage extends StatelessWidget {
  const EditSharedContactPage({
    required this.sharedContact,
    required this.onSave,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  final SharedContact sharedContact;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SharedContactFormCubit>(
      create: (_) => SharedContactFormCubit(),
      child: SharedContactForm(
        sharedContact: sharedContact,
        title: context.msg.main.contacts.list.editSharedContact.title,
        onSave: onSave,
        onDelete: onDelete,
      ),
    );
  }
}
