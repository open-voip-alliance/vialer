import 'package:equatable/equatable.dart';

import '../../../../../domain/entities/temporary_redirect.dart';

abstract class TemporaryRedirectPickerState extends Equatable {
  const TemporaryRedirectPickerState();

  @override
  final props = const [];
}

class LoadingDestinations extends TemporaryRedirectPickerState {
  const LoadingDestinations();
}

class LoadedDestinations extends TemporaryRedirectPickerState {
  final TemporaryRedirectDestination currentDestination;
  final Iterable<TemporaryRedirectDestination> availableDestinations;

  const LoadedDestinations(
    this.currentDestination,
    this.availableDestinations,
  );

  LoadedDestinations copyWith({
    TemporaryRedirectDestination? currentDestination,
    Iterable<TemporaryRedirectDestination>? availableDestinations,
  }) {
    return LoadedDestinations(
      currentDestination ?? this.currentDestination,
      availableDestinations ?? this.availableDestinations,
    );
  }

  @override
  List<Object?> get props => [currentDestination, availableDestinations];
}
