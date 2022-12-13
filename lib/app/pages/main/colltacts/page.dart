import 'package:flutter/material.dart';

import '../widgets/contact_list/widget.dart';
import 'widgets/details/widget.dart';

class ContactsPage extends StatelessWidget {
  final double bottomLettersPadding;
  final GlobalKey<NavigatorState>? navigatorKey;

  const ContactsPage({
    Key? key,
    this.navigatorKey,
    this.bottomLettersPadding = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: ContactList(
          navigatorKey: navigatorKey,
          bottomLettersPadding: bottomLettersPadding,
          detailsBuilder: (_, contact) => ContactPageDetails(contact: contact),
        ),
      ),
    );
  }
}
