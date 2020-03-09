import '../../domain/entities/system_user.dart';
import '../../domain/entities/setting.dart';

abstract class StorageRepository {
  Future<void> load();

  SystemUser get systemUser;

  set systemUser(SystemUser user);

  String get apiToken;

  set apiToken(String token);

  List<Setting> get settings;

  set settings(List<Setting> settings);

  Future<void> clear();
}
