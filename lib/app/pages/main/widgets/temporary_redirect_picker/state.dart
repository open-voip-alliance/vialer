import 'package:equatable/equatable.dart';

import '../../../../../domain/business_availability/temporary_redirect/temporary_redirect.dart';

abstract class TemporaryRedirectPickerState extends Equatable {
  const TemporaryRedirectPickerState();

  @override
  final props = const [];
}

class LoadedDestinations extends TemporaryRedirectPickerState {
  final TemporaryRedirectDestination? currentlySelectedDestination;
  final Iterable<TemporaryRedirectDestination> availableDestinations;

  const LoadedDestinations(
    this.currentlySelectedDestination,
    this.availableDestinations,
  );

  LoadedDestinations copyWith({
    TemporaryRedirectDestination? currentlySelectedDestination,
    Iterable<TemporaryRedirectDestination>? availableDestinations,
  }) {
    return LoadedDestinations(
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
