import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/caller.dart';

import 'state.dart';

class ContactDetailsCubit extends Cubit<ContactDetailsState> {
  final CallerCubit _caller;

  ContactDetailsCubit(this._caller) : super(ContactDetailsState());

  Future<void> call(String destination) =>
      _caller.call(destination, origin: CallOrigin.contacts);

  Future<void> requestPermission() async {
    await _caller.requestPermission();
  }

  void mail(String destination) {
    launch('mailto:$destination');
  }
}
