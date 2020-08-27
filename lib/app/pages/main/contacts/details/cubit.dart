import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/caller.dart';

import '../../../../util/debug.dart';

import 'state.dart';

class ContactDetailsCubit extends Cubit<ContactDetailsState> {
  final CallerCubit _caller;

  ContactDetailsCubit(this._caller) : super(ContactDetailsState());

  Future<void> call(String destination) async {
    doIfNotDebug(() {
      Segment.track(eventName: 'call', properties: {'via': 'contact'});
    });

    await _caller.call(destination);
  }

  void mail(String destination) {
    launch('mailto:$destination');
  }
}
