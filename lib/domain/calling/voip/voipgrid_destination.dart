import 'destination.dart';

abstract class VoipgridDestination {
  int? get id;

  String? get description;

  const VoipgridDestination();

  Destination toDestination();
}
