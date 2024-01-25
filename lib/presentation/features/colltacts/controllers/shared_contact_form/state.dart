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

  const factory SharedContactFormState.saved() = Saved;

  const factory SharedContactFormState.deleted() = Deleted;

  const factory SharedContactFormState.error({
    String? uuid,
    String? firstName,
    String? lastName,
    String? company,
    List<String>? phoneNumbers,
  }) = Error;
}
