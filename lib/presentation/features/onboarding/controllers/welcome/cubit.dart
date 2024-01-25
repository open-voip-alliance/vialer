import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../domain/usecases/user/get_stored_user.dart';
import 'state.dart';

export 'state.dart';

class WelcomeCubit extends Cubit<WelcomeState> {
  WelcomeCubit() : super(WelcomeState(user: GetStoredUserUseCase()()));
}
