import 'package:equatable/equatable.dart';

import '../../../domain/entities/brand.dart';

class BrandProviderState extends Equatable {
  final Brand brand;

  const BrandProviderState(this.brand);

  @override
  List<Object> get props => [brand];
}
