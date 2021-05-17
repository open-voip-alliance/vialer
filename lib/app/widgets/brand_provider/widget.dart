import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/brand.dart';
import '../../resources/theme.dart';
import 'cubit.dart';

class BrandProvider extends StatelessWidget {
  /// If set, this is the Brand that will always be provided, regardless
  /// of build settings. Useful for testing.
  final Brand? brand;
  final Widget child;

  /// Provides a [Brand] and [BrandTheme] to its children.
  const BrandProvider({
    this.brand,
    required this.child,
  });

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
