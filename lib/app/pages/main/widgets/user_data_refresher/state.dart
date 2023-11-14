import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

@freezed
sealed class UserDataRefresherState with _$UserDataRefresherState {
  const factory UserDataRefresherState.notRefreshing() = NotRefreshing;
  const factory UserDataRefresherState.refreshing() = Refreshing;
}