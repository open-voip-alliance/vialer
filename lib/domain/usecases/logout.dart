import '../repositories/storage.dart';
import '../use_case.dart';

class LogoutUseCase extends FutureUseCase<void> {
  final StorageRepository _storageRepository;

  LogoutUseCase(this._storageRepository);

  @override
  Future<void> call() => _storageRepository.clear();
}
