import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:search_highlight_text/search_highlight_text.dart';
import 'package:vialer/data/models/colltacts/colltact_tab.dart';
import 'package:vialer/presentation/features/colltacts/controllers/cubit.dart';
import 'package:vialer/presentation/features/colltacts/widgets/colltact_list/colltact_item_list.dart';
import 'package:vialer/presentation/features/colltacts/widgets/colltact_list/util/kind.dart';
import 'package:vialer/presentation/features/colltacts/widgets/colltact_list/websocket_unreachable_notice.dart';
import 'package:vialer/presentation/resources/localizations.dart';

import '../../../../../../data/models/colltacts/colltact.dart';
import '../../../../shared/widgets/bottom_toggle.dart';
import '../../../../shared/widgets/flexible_tab_bar_view.dart';
import '../../../../shared/widgets/nested_navigator.dart';
import '../../../../util/widgets_binding_observer_registrar.dart';
import '../../../settings/widgets/settings_button.dart';
import '../../controllers/colleagues/cubit.dart';
import '../../controllers/contacts/cubit.dart';
import '../../controllers/shared_contacts/cubit.dart';
import '../../pages/add_shared_contact/page.dart';
import 'colltacts_tab_bar.dart';
import 'search.dart';

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
      unawaited(
        context
            .read<SharedContactsCubit>()
            .loadSharedContacts(fullRefresh: true),
      );
    }
  }

  void _buildTabController(BuildContext context, List<ColltactTab> tabs) {
    final cubit = context.read<ColltactsTabsCubit>();
    final numberOfTabs = tabs.length;

    final shouldRebuildTabController =
        this.tabController?.length != numberOfTabs;

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
                WebSocketUnreachableNotice(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SearchTextField(onChanged: _onSearchTermChanged),
                ),
                ColltactsTabBar(controller: tabController),
                Expanded(
                  child: FlexibleTabBarView(
                    controller: tabController,
                    children: tabs.widgets(
                      (tab) => switch (tab) {
                        ColltactTab.contacts =>
                          ColltactItemList(ColltactKind.contact),
                        ColltactTab.sharedContact => SharedContactItemList(),
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

class SharedContactItemList extends StatelessWidget {
  const SharedContactItemList({
    super.key,
  });

  Widget _addSharedContactButton(
    BuildContext context,
    SharedContactsCubit sharedContactsCubit,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SettingsButton(
        onPressed: () => unawaited(
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                return AddSharedContactPage(
                  onSave: () => sharedContactsCubit.loadSharedContacts(
                    fullRefresh: true,
                  ),
                );
              },
            ),
          ),
        ),
        solid: false,
        icon: FontAwesomeIcons.userPlus,
        text: context.msg.main.contacts.list.addSharedContact.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SharedContactsCubit, SharedContactsState>(
      builder: (_, state) {
        final sharedContactsCubit = context.read<SharedContactsCubit>();
        final sharedContactsState = sharedContactsCubit.state;

        return Column(
          children: [
            if (sharedContactsState.isLoadedWithNoEmptyList)
              _addSharedContactButton(context, sharedContactsCubit),
            Expanded(
              child: ColltactItemList(ColltactKind.sharedContact),
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
        // Required otherwise the search_highlight_text package throws an
        // exception when searching for reserved regex characters.
        searchText: RegExp.escape(search),
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
