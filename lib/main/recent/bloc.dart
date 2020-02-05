import 'package:bloc/bloc.dart';
import 'package:vialer_lite/main/recent/item.dart';

import 'event.dart';
import 'state.dart';

export 'event.dart';
export 'state.dart';

class RecentBloc extends Bloc<RecentEvent, RecentState> {
  @override
  RecentState get initialState => RecentsLoaded(
        List.generate(64, (i) {
          return RecentCall(
            isIncoming: i % 8 == 0,
            name: i % 6 == 0 ? 'Mark Vletter' : null,
            phoneNumber: '+315072000035',
            time: DateTime.now().subtract(Duration(minutes: i * 3)),
          );
        }),
      );

  @override
  Stream<RecentState> mapEventToState(RecentEvent event) async* {}
}
