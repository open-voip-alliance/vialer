import '../repositories/storage.dart';
import '../use_case.dart';

class GetLatestDialedNumber extends UseCase<String> {
  final StorageRepository _storageRepository;

  GetLatestDialedNumber(this._storageRepository);

  @override
  String call() => _storageRepository.lastDialedNumber;
}
