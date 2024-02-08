import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../controllers/colleagues/cubit.dart';
import '../../controllers/contacts/cubit.dart';
import '../../controllers/shared_contacts/cubit.dart';

part 'colltact_bloc_builder.freezed.dart';

/// Allows a widget to conveniently build based on all of the available cubits
/// relating to Colltacts.
class ColltactBlocBuilder extends StatelessWidget {
  const ColltactBlocBuilder({required this.builder, super.key});

  final Widget Function(ColltactBlocBuilderContainer) builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactsCubit, ContactsState>(
      builder: (context, contactsState) =>
          BlocBuilder<ColleaguesCubit, ColleaguesState>(
        builder: (context, colleaguesState) =>
            BlocBuilder<SharedContactsCubit, SharedContactsState>(
          builder: (context, sharedContactsState) => builder(
            ColltactBlocBuilderContainer(
              contactsCubit: context.watch<ContactsCubit>(),
              contactsState: contactsState,
              colleaguesCubit: context.watch<ColleaguesCubit>(),
              colleaguesState: colleaguesState,
              sharedContactsCubit: context.watch<SharedContactsCubit>(),
              sharedContactsState: sharedContactsState,
            ),
          ),
        ),
      ),
    );
  }
}

@freezed
class ColltactBlocBuilderContainer with _$ColltactBlocBuilderContainer {
  const factory ColltactBlocBuilderContainer({
    required ContactsCubit contactsCubit,
    required ContactsState contactsState,
    required ColleaguesCubit colleaguesCubit,
    required ColleaguesState colleaguesState,
    required SharedContactsCubit sharedContactsCubit,
    required SharedContactsState sharedContactsState,
  }) = _ColltactBlocBuilderContainer;
}
