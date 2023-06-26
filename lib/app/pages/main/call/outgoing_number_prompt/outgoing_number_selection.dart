import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vialer/domain/user/get_logged_in_user.dart';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/calling/outgoing_number/change_outgoing_number.dart';
import '../../../../../domain/legacy/storage.dart';
import '../../../../../domain/metrics/metrics.dart';
import '../../../../../domain/user/settings/call_setting.dart';
import '../../../../../domain/user/user.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'outgoing_number_selection.g.dart';

part 'outgoing_number_selection.freezed.dart';

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
      'doNotShowAgain': doNotShowAgain,
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
