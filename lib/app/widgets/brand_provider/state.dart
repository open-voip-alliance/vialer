import 'package:equatable/equatable.dart';

import '../../../domain/user/brand.dart';

class BrandProviderState extends Equatable {
  const BrandProviderState(this.brand);

  final Brand brand;

  @override
  List<Object?> get props => [brand];
}
