import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:search_highlight_text/search_highlight_text.dart';
import 'package:vialer/app/pages/main/colltacts/cubit.dart';
import 'package:vialer/app/pages/main/colltacts/widgets/colltact_list/util/kind.dart';
import 'package:vialer/app/pages/main/colltacts/widgets/colltact_list/widgets/colltact_item_list.dart';
import 'package:vialer/app/pages/main/colltacts/widgets/colltact_list/widgets/websocket_unreachable_notice.dart';
import 'package:vialer/domain/colltacts/colltact_tab.dart';

import '../../../../../../data/models/colltact.dart';
import '../../../../../resources/localizations.dart';
import '../../../../../util/widgets_binding_observer_registrar.dart';
import '../../../colltacts/colleagues/cubit.dart';
import '../../../colltacts/shared_contacts/cubit.dart';
import '../../../colltacts/contacts/cubit.dart';
import '../../../widgets/bottom_toggle.dart';
import '../../../widgets/flexible_tab_bar_view.dart';
import '../../../widgets/nested_navigator.dart';
import 'widgets/search.dart';
import 'widgets/colltacts_tab_bar.dart';

abstract class ColltactsPageRoutes {
  static const root = '/';
  static const details = '/details';
}

typedef WidgetWithColltactBuilder = Widget Function(BuildContext, Colltact);

class ColltactList extends StatelessWidget {
  const ColltactList({
    required this.detailsBuilder,
    this.bottomLettersPadding = 0,
    this.navigatorKey,
    super.key,
  });

  final GlobalKey<NavigatorState>? navigatorKey;
  final WidgetWithColltactBuilder detailsBuilder;
  final double bottomLettersPadding;

  @override
  Widget build(BuildContext context) {
    return NestedNavigator(
      navigatorKey: navigatorKey,
      routes: {
        ColltactsPageRoutes.root: (_, __) => const _ColltactList(),
        ColltactsPageRoutes.details: (context, colltact) =>
            detailsBuilder(context, colltact! as Colltact),
      },
    );
  }
}

class _ColltactList extends StatefulWidget {
  const _ColltactList({
    // ignore: unused_element
    this.bottomLettersPadding = 0,
  });

  final double bottomLettersPadding;

  @override
  _ColltactPageState createState() => _ColltactPageState();
}

class _ColltactPageState extends State<_ColltactList>
    with
        WidgetsBindingObserver,
        WidgetsBindingObserverRegistrar,
        TickerProviderStateMixin {
  String? _searchTerm;
  TabController? tabController;

  @override
  void initState() {
    super.initState();
    _buildTabController(context, context.read<ColltactsTabsCubit>().state);
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  void _onSearchTermChanged(String searchTerm) {
    setState(() {
      _searchTerm = searchTerm;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      unawaited(context.read<ContactsCubit>().reloadContacts());
      unawaited(context
          .read<SharedContactsCubit>()
          .loadSharedContacts(fullRefresh: true));
    }
  }

  void _buildTabController(BuildContext context, List<ColltactTab> tabs) {
    final cubit = context.read<ColltactsTabsCubit>();
    final numberOfTabs = tabs.length;

    final shouldRebuildTabController =
        numberOfTabs > 1 && this.tabController?.length != numberOfTabs;

    if (!shouldRebuildTabController) return;

    final tabController = TabController(
      initialIndex: cubit.getStoredTabAsIndex(),
      length: numberOfTabs,
      vsync: this,
    );

    this.tabController = tabController
      ..addListener(() {
        if (!tabController.indexIsChanging) {
          cubit.storeCurrentTab(tabController.index);
          cubit.trackTabSelected(tabController.index);
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return _SearchText(
      searchText: _searchTerm ?? '',
      bottomLettersPadding: widget.bottomLettersPadding,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: BlocBuilder<ColltactsTabsCubit, List<ColltactTab>>(
          builder: (context, tabs) {
            // We need to rebuild the tab controller to handle if the number
            // of tabs we are showing has changed.
            _buildTabController(context, tabs);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                WebsocketUnreachableNotice(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SearchTextField(onChanged: _onSearchTermChanged),
                ),
                if (tabs.length > 1) ColltactsTabBar(controller: tabController),
                Expanded(
                  child: FlexibleTabBarView(
                    controller: tabController,
                    children: tabs.widgets(
                      (tab) => switch (tab) {
                        ColltactTab.contacts =>
                          ColltactItemList(ColltactKind.contact),
                        ColltactTab.sharedContact =>
                          ColltactItemList(ColltactKind.sharedContact),
                        ColltactTab.colleagues => ColleagueItemList(),
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ColleagueItemList extends StatelessWidget {
  const ColleagueItemList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ColleaguesCubit, ColleaguesState>(
      builder: (_, state) {
        final colleaguesCubit = context.watch<ColleaguesCubit>();
        return Column(
          children: [
            Expanded(
              child: ColltactItemList(ColltactKind.colleague),
            ),
            BottomToggle(
              name: context.msg.main.colleagues.toggle,
              initialValue: colleaguesCubit.showOnlineColleaguesOnly,
              onChanged: (value) =>
                  colleaguesCubit.showOnlineColleaguesOnly = value,
            ),
          ],
        );
      },
    );
  }
}

/// Using an inherited widget to pass information down to the individual tabs
/// so we don't need to manually pass the data around.
class ColltactTabsInheritedWidget extends InheritedWidget {
  const ColltactTabsInheritedWidget({
    super.key,
    required this.searchTerm,
    required this.bottomLettersPadding,
    required Widget child,
  }) : super(child: child);

  final String searchTerm;
  final double bottomLettersPadding;

  static ColltactTabsInheritedWidget of(BuildContext context) {
    final ColltactTabsInheritedWidget? result = context
        .dependOnInheritedWidgetOfExactType<ColltactTabsInheritedWidget>();
    assert(result != null, 'No ColltactTabsInheritedWidget found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ColltactTabsInheritedWidget old) =>
      old.searchTerm != searchTerm;
}

class _SearchText extends StatelessWidget {
  const _SearchText({
    required this.searchText,
    required this.bottomLettersPadding,
    required this.child,
  });

  final Widget child;
  final String? searchText;
  final double bottomLettersPadding;

  @override
  Widget build(BuildContext context) {
    final search = searchText ?? '';

    return ColltactTabsInheritedWidget(
      searchTerm: search,
      bottomLettersPadding: bottomLettersPadding,
      child: SearchTextInheritedWidget(
        searchText: search,
        highlightStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 17,
        ),
        child: child,
      ),
    );
  }
}
