import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/presentation/resources/localizations.dart';

import '../../controllers/shared_contact_form/cubit.dart';
import '../../widgets/shared_contact_form/widget.dart';

class AddSharedContactPage extends StatelessWidget {
  const AddSharedContactPage({
    required this.onSave,
    Key? key,
  }) : super(key: key);

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SharedContactFormCubit>(
      create: (_) => SharedContactFormCubit(),
      child: SharedContactForm(
        title: context.msg.main.contacts.list.addSharedContact.title,
        onSave: onSave,
      ),
    );
  }
}
