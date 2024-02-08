import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/models/calling/outgoing_number/outgoing_number.dart';
import '../../../../data/models/user/settings/call_setting.dart';
import '../../../../data/models/user/user.dart';
import '../../../../data/repositories/legacy/storage.dart';
import '../../../../data/repositories/metrics/metrics.dart';
import '../../../../dependency_locator.dart';
import '../../../../domain/usecases/calling/outgoing_number/change_outgoing_number.dart';
import '../../../../domain/usecases/user/get_logged_in_user.dart';

part 'outgoing_number_selection.freezed.dart';
part 'outgoing_number_selection.g.dart';

@riverpod
class OutgoingNumberSelection extends _$OutgoingNumberSelection {
  User get _user => GetLoggedInUserUseCase()();

  Iterable<OutgoingNumber> get outgoingNumbers => _user.client.outgoingNumbers;
  bool get shouldShowAgain =>
      _storageRepository.doNotShowOutgoingNumberSelector;
  OutgoingNumber get currentOutgoingNumber =>
      _user.settings.get(CallSetting.outgoingNumber);
  final _changeOutgoingNumber = ChangeOutgoingNumber();
  late final _metrics = dependencyLocator<MetricsRepository>();
  final _storageRepository = dependencyLocator<StorageRepository>();

  @override
  OutgoingNumberSelectorState build() {
    return OutgoingNumberSelectorState.ready(
      outgoingNumbers.toList(),
      _storageRepository.recentOutgoingNumbers,
      currentOutgoingNumber,
      _storageRepository.doNotShowOutgoingNumberSelector,
    );
  }

  void doNotShowAgain(bool value) {
    _storageRepository.doNotShowOutgoingNumberSelector = value;
    state = state.copyWith(doNotShowAgain: value);
  }

  Future<bool> changeOutgoingNumber({
    required OutgoingNumber number,
  }) async {
    // If we already have the correct outgoing number set, we don't need to
    // do anything.
    if (currentOutgoingNumber == number) {
      _metrics.track('outgoing-number-prompt-current-used');
      return true;
    }

    state = OutgoingNumberSelectorState.updating(
      state.outgoingNumbers,
      state.recentOutgoingNumbers,
      currentOutgoingNumber,
      state.doNotShowAgain,
    );

    final success = await _changeOutgoingNumber(number, refreshUser: true);

    _metrics.track('outgoing-number-prompt-number-changed', {
      'success': success,
      'doNotShowAgain': state.doNotShowAgain,
    });

    if (state.doNotShowAgain) {
      _storageRepository.doNotShowOutgoingNumberSelector = true;
    }

    state = success
        ? OutgoingNumberSelectorState.ready(
            state.outgoingNumbers,
            state.recentOutgoingNumbers,
            currentOutgoingNumber,
            state.doNotShowAgain,
          )
        : OutgoingNumberSelectorState.failed(
            state.outgoingNumbers,
            state.recentOutgoingNumbers,
            currentOutgoingNumber,
            state.doNotShowAgain,
          );

    return success;
  }
}

@freezed
sealed class OutgoingNumberSelectorState with _$OutgoingNumberSelectorState {
  const factory OutgoingNumberSelectorState.ready(
    Iterable<OutgoingNumber> outgoingNumbers,
    Iterable<OutgoingNumber> recentOutgoingNumbers,
    OutgoingNumber currentOutgoingNumber,
    bool doNotShowAgain,
  ) = Ready;

  const factory OutgoingNumberSelectorState.updating(
    Iterable<OutgoingNumber> outgoingNumbers,
    Iterable<OutgoingNumber> recentOutgoingNumbers,
    OutgoingNumber currentOutgoingNumber,
    bool doNotShowAgain,
  ) = Updating;

  const factory OutgoingNumberSelectorState.failed(
    Iterable<OutgoingNumber> outgoingNumbers,
    Iterable<OutgoingNumber> recentOutgoingNumbers,
    OutgoingNumber currentOutgoingNumber,
    bool doNotShowAgain,
  ) = Failed;
}
