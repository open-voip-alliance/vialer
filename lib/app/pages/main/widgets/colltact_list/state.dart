import 'package:equatable/equatable.dart';

import '../../../../../../app/util/pigeon.dart';
import '../../../../../data/models/colltact.dart';

abstract class ColltactsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadingColltacts extends ColltactsState {}

class NoPermission extends ColltactsState {
  final bool dontAskAgain;

  NoPermission({required this.dontAskAgain});

  @override
  List<Object?> get props => [dontAskAgain];
}

class ColltactsLoaded extends ColltactsState {
  final Iterable<Colltact> colltacts;
  final ContactSort? contactSort;

  ColltactsLoaded(this.colltacts, this.contactSort);

  @override
  List<Object?> get props => [colltacts];
}
