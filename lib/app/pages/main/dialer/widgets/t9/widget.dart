import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../domain/colltacts/t9_colltact.dart';
import '../../../../../../domain/metrics/track_t9_usage.dart';
import '../../../../../util/contact.dart';
import '../../../widgets/colltact_list/widgets/avatar.dart';
import 'bloc.dart';

class T9ColltactsListView extends StatelessWidget {
  const T9ColltactsListView({
    required this.controller,
    super.key,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<T9ColltactsBloc>(
      create: (_) => T9ColltactsBloc(),
      child: _T9ColltactsList(
        controller: controller,
      ),
    );
  }
}

class _T9ColltactsList extends StatefulWidget {
  const _T9ColltactsList({required this.controller});

  final TextEditingController controller;

  @override
  _T9ColltactsListState createState() => _T9ColltactsListState();
}

class _T9ColltactsListState extends State<_T9ColltactsList> {
  final _listKey = GlobalKey();

  final _scrollController = ScrollController();

  double? _height;
  bool _notifiedScrollbar = false;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_onInputChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox =
          _listKey.currentContext!.findRenderObject()! as RenderBox;

      setState(() {
        // Height of the list will be 2 items.
        _height = renderBox.size.height * 2;
      });
    });
  }

  void _onStateChanged(BuildContext context, T9ColltactsState state) {
    // Due to a possible bug in the Scrollbar widget, it does not show the
    // scrollbar when the amount of items goes from zero to non-zero.
    // Below is a workaround, inspired by the Flutter source code: they make
    // the scrollbar appear by sending an empty scroll notification. So that's
    // what we do when there are enough items. After the scrollbar is
    // triggered it's not a problem  anymore, so we do it only once
    // (there's no harm in doing it multiple times, just unnecessary).
    if (!_notifiedScrollbar &&
        state is ColltactsLoaded &&
        state.filteredColltacts.length >= 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // The empty scroll notification.
        _scrollController.position.didUpdateScrollPositionBy(0);
        _notifiedScrollbar = true;
      });
    }
  }

  void _onInputChanged() {
    context
        .read<T9ColltactsBloc>()
        .add(FilterT9Colltacts(widget.controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<T9ColltactsBloc, T9ColltactsState>(
      listener: _onStateChanged,
      builder: (context, state) {
        final contacts =
            state is ColltactsLoaded ? state.filteredColltacts : <T9Colltact>[];

        return SizedBox(
          // If the height has not been calculated yet (first frame), use the
          // default two-line ListTile height, extracted from Flutter
          // source code.
          height: _height ?? (76.0 * 2),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              // In the first frame we put 1 dummy ListTile in the list, to
              // get the size we need for the list itself.
              itemCount:
                  _height == null ? max(contacts.length, 1) : contacts.length,
              itemBuilder: (context, index) {
                final t9Colltact =
                    contacts.length > index ? contacts[index] : null;

                // This happens on the first frame,
                // to calculate the size of the list.
                if (t9Colltact == null) {
                  return Visibility(
                    visible: false,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: ListTile(
                      // We only want the GlobalKey to be used once in the tree.
                      // Even without the check it should be used only once,
                      // but better to be safe than sorry.
                      key: index == 0 ? _listKey : null,
                      leading: const SizedBox(
                        height: ColltactAvatar.defaultSize,
                      ),
                      title: const Text(''),
                      subtitle: const Text(''),
                    ),
                  );
                }

                return ListTile(
                  leading: ColltactAvatar(t9Colltact.colltact),
                  title: Text(
                    t9Colltact.colltact.when(
                      colleague: (colleague) => colleague.name,
                      contact: (contact) => contact.displayName,
                      sharedContact: (sharedContact) =>
                          sharedContact.displayName,
                    ),
                  ),
                  subtitle: Text(t9Colltact.relevantPhoneNumber.value),
                  onTap: () {
                    unawaited(TrackT9Usage()(t9Colltact.colltact));
                    widget.controller.text =
                        t9Colltact.relevantPhoneNumber.value;
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onInputChanged);
    _scrollController.dispose();

    super.dispose();
  }
}
