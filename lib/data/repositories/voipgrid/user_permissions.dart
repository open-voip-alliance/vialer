import 'package:dartx/dartx.dart';
import 'package:injectable/injectable.dart';

import '../../../presentation/util/loggable.dart';
import '../../API/voipgrid/voipgrid_service.dart';
import '../../models/user/user.dart';
import '../../models/vialer.dart';
import '../legacy/storage.dart';

@singleton
class UserPermissionsRepository with Loggable {
  UserPermissionsRepository(this._service, this._storage);

  final VoipgridService _service;
  final StorageRepository _storage;

  static const _permissionsMapping = {
    'cdr.view_record': VoipgridPermission.clientCalls,
    'permission.change_user': VoipgridPermission.changeMobileNumberFallback,
    // There is only one temporary redirect permission, it is not separated
    // between viewing and changing.
    'business_availability.change_temporary_redirect':
        VoipgridPermission.temporaryRedirect,
    'voicemail.view_voicemail': VoipgridPermission.viewVoicemail,
    'phoneaccount.change_phoneaccount': VoipgridPermission.changeVoipAccount,
    'phoneaccount.list_api_voipaccount_basic_info':
        VoipgridPermission.listVoipAccounts,
    'permission.list_api_user_basic_info': VoipgridPermission.listUsers,
    'routing.view_routing': VoipgridPermission.viewRouting,
    'stats.view_stats': VoipgridPermission.viewStats,
    'openinghours.change_openinghoursgroup':
        VoipgridPermission.changeOpeningHours,
    'appaccount.change_appaccount': VoipgridPermission.changeAppAccount,
  };

  Future<List<VoipgridPermission>> getGrantedPermissions({
    required User user,
  }) async {
    final response = await _service.getVoipgridPermissions();

    if (!response.isSuccessful) {
      logFailedResponse(response);
      throw UnableToRetrievePermissionsException();
    }

    final body = response.body!;

    final grantedPermissions = body['permissions'] as List<dynamic>;

    // Storing the raw permissions so we can submit these to metrics later.
    _storage.grantedVoipgridPermissions =
        grantedPermissions.toRawPermissionsList();

    return grantedPermissions
        .map(
          (dynamic permission) => _permissionsMapping.containsKey(permission)
              ? _permissionsMapping[permission]
              : null,
        )
        .filterNotNull()
        .toList(growable: false);
  }
}

enum VoipgridPermission {
  clientCalls,
  viewMobileNumberFallback,
  changeMobileNumberFallback,
  temporaryRedirect,
  viewVoicemail,
  changeVoipAccount,
  listVoipAccounts,
  listUsers,
  viewStats,
  viewRouting,
  changeOpeningHours,
  changeAppAccount,
}

enum Permission {
  canSeeClientCalls,
  canChangeMobileNumberFallback,
  @Deprecated(
    'Permission is no longer necessary but this enum must '
    'still exist for deserializing old users',
  )
  canViewMobileNumberFallbackStatus,
  canChangeTemporaryRedirect,
  canViewVoicemailAccounts,
  canChangeOutgoingNumber,
  canViewColleagues,
  canViewVoipAccounts,
  canViewDialPlans,
  canViewStats,
  canChangeOpeningHours,
  canChangeAppAccount,
}

class UnableToRetrievePermissionsException extends VialerException {}
