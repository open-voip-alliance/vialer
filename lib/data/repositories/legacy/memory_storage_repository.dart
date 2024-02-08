import 'package:injectable/injectable.dart';

@singleton
class MemoryStorageRepository {
  String? regionNumber;

  void clearRegionNumber() => regionNumber = null;
}
