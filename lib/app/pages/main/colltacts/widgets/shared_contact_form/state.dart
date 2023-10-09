import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

@freezed
sealed class SharedContactFormState with _$SharedContactFormState {
  const factory SharedContactFormState.idle({
    String? firstName,
    String? lastName,
    String? company,
    List<String>? phoneNumbers,
  }) = Idle;

  const factory SharedContactFormState.inProgress() = InProgress;

  const factory SharedContactFormState.success() = Success;

  const factory SharedContactFormState.error({
    String? firstName,
    String? lastName,
    String? company,
    List<String>? phoneNumbers,
  }) = Error;
}
