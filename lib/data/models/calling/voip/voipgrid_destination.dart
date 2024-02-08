import 'destination.dart';

abstract class VoipgridDestination {
  const VoipgridDestination();

  int? get id;

  String? get description;

  Destination toDestination();
}
