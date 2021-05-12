import '../../app/util/loggable.dart';
import '../../dependency_locator.dart';
import '../repositories/auth.dart';
import '../use_case.dart';
import 'get_mobile_number.dart';
import 'metrics/track_change_mobile_number.dart';

class ChangeMobileNumberUseCase extends UseCase with Loggable {
  final _authRepository = dependencyLocator<AuthRepository>();
  final _getMobileNumber = GetMobileNumberUseCase();
  final _trackChangeMobileNumber = TrackChangeMobileNumberUseCase();

  Future<bool> call({required String mobileNumber}) async {
    final success = await _authRepository.changeMobileNumber(mobileNumber);
    if (success) {
      _trackChangeMobileNumber();
      await _getMobileNumber(latest: true);
    }
    logger.info('Updating of mobile number succeeded: $success');
    return success;
  }
}
