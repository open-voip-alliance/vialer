import 'package:equatable/equatable.dart';

import '../../../../../domain/business_availability/temporary_redirect/temporary_redirect.dart';

class TemporaryRedirectPickerState extends Equatable {
  final TemporaryRedirectDestination? currentlySelectedDestination;
  final Iterable<TemporaryRedirectDestination> availableDestinations;

  const TemporaryRedirectPickerState(
    this.currentlySelectedDestination,
    this.availableDestinations,
  );

  TemporaryRedirectPickerState copyWith({
    TemporaryRedirectDestination? currentlySelectedDestination,
    Iterable<TemporaryRedirectDestination>? availableDestinations,
  }) {
    return TemporaryRedirectPickerState(
      currentlySelectedDestination ?? this.currentlySelectedDestination,
      availableDestinations ?? this.availableDestinations,
    );
  }

  @override
  List<Object?> get props => [
        currentlySelectedDestination,
        availableDestinations,
      ];
}
