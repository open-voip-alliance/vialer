import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class RecentCall extends Equatable {
  final bool isIncoming;
  final String phoneNumber;
  final DateTime time;

  final String name;

  RecentCall({
    @required this.phoneNumber,
    @required this.time,
    @required this.isIncoming,
    this.name,
  });

  @override
  List<Object> get props => [phoneNumber, time, name];
}
