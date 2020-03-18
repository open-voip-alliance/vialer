import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:intl/intl.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';

import '../../../../../domain/entities/contact.dart';
import '../../../../../domain/repositories/contact.dart';

import '../../../../../domain/repositories/call.dart';

import '../widgets/avatar.dart';
import '../widgets/subtitle.dart';
import '../../widgets/header.dart';

import 'controller.dart';

class ContactDetailsPage extends View {
  final ContactRepository _contactsRepository;
  final CallRepository _callRepository;

  final Contact contact;
  final double bottomLettersPadding;

  ContactDetailsPage(
    this._contactsRepository,
    this._callRepository, {
    Key key,
    @required this.contact,
    this.bottomLettersPadding = 0,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _ContactDetailsPageState(_contactsRepository, _callRepository);
}

class _ContactDetailsPageState
    extends ViewState<ContactDetailsPage, ContactDetailsController> {
  _ContactDetailsPageState(
    ContactRepository contactRepository,
    CallRepository callRepository,
  ) : super(ContactDetailsController(contactRepository, callRepository));

  @override
  Widget buildPage() {
    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Header(context.msg.main.contacts.title),
        centerTitle: false,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
              ).copyWith(
                top: 32,
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      ContactAvatar(widget.contact, size: 48),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.contact.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          ContactSubtitle(widget.contact),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 24),
                  _DestinationsList(
                    contact: widget.contact,
                    onTapNumber: controller.call,
                    onTapEmail: controller.mail,
                  ),
                ],
              ),
            ),
          ],
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
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
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
      contentPadding: EdgeInsets.only(left: 8),
      leading: Container(
        width: 36,
        alignment: Alignment.center,
        child: Icon(isEmail ? VialerSans.mail : VialerSans.phone),
      ),
      title: Text(value),
      subtitle: Text(label),
      onTap: onTap,
    );
  }
}
