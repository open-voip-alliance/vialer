import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/user/brand.dart';
import '../../../resources/theme.dart';
import '../../controllers/brand_provider/cubit.dart';

class BrandProvider extends StatelessWidget {
  /// Provides a [Brand] and [BrandTheme] to its children.
  const BrandProvider({
    required this.child,
    this.brand,
    super.key,
  });

  /// If set, this is the Brand that will always be provided, regardless
  /// of build settings. Useful for testing.
  final Brand? brand;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (brand != null) {
      return Provider<Brand>.value(
        value: brand!,
        child: child,
      );
    }

    return BlocProvider<BrandProviderCubit>(
      create: (_) => BrandProviderCubit(),
      child: BlocBuilder<BrandProviderCubit, BrandProviderState>(
        builder: (context, state) {
          return Provider<Brand>.value(
            value: state.brand,
            child: child,
          );
        },
      ),
    );
  }
}
