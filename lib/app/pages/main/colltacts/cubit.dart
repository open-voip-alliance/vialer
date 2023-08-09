import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/app/pages/main/colltacts/colleagues/cubit.dart';
import 'package:vialer/app/pages/main/colltacts/contacts/cubit.dart';
import 'package:vialer/app/pages/main/colltacts/shared_contacts/cubit.dart';
import 'package:vialer/app/pages/main/colltacts/widgets/colltact_list/util/kind.dart';
import 'package:vialer/domain/metrics/metrics.dart';

import '../../../../dependency_locator.dart';
import '../../../../domain/colltacts/colltact_tab.dart';
import '../../../../domain/legacy/storage.dart';

class ColltactsTabsCubit extends Cubit<List<ColltactTab>> {
  ColltactsTabsCubit(
    this.contactsCubit,
    this.colleaguesCubit,
    this.sharedContactsCubit,
  ) : super([]) {
    contactsCubit.stream.listen((_) => _rebuildTabs());
    colleaguesCubit.stream.listen((_) => _rebuildTabs());
    sharedContactsCubit.stream.listen((_) => _rebuildTabs());
  }

  final ContactsCubit contactsCubit;
  final ColleaguesCubit colleaguesCubit;
  final SharedContactsCubit sharedContactsCubit;

  final _storageRepository = dependencyLocator<StorageRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  /// A virtual list of our current tabs, these will be used to render
  /// from in the widgets and allows us to easily look-up our position.
  List<ColltactTab> get _tabs => [
        if (_shouldShow(kind: ColltactKind.contact)) ColltactTab.contacts,
        if (_shouldShow(kind: ColltactKind.sharedContact))
          ColltactTab.sharedContact,
        if (_shouldShow(kind: ColltactKind.colleague)) ColltactTab.colleagues,
      ];

  void trackTabSelected(int index) =>
      _metricsRepository.track(switch (_indexToTab(index)) {
        ColltactTab.contacts => 'contacts-tab-selected',
        ColltactTab.sharedContact => 'shared-contacts-tab-selected',
        ColltactTab.colleagues => 'colleague-tab-selected',
      });

  int getStoredTabAsIndex() {
    final index = _tabToIndex(
      _storageRepository.currentColltactTab ?? ColltactTab.contacts,
    );

    return index >= 0 ? index : 0;
  }

  void storeCurrentTab(int index) =>
      _storageRepository.currentColltactTab = _indexToTab(index);

  void _rebuildTabs() => emit(_tabs);

  bool _shouldShow({required ColltactKind kind}) => switch (kind) {
        ColltactKind.contact => true,
        ColltactKind.sharedContact =>
          sharedContactsCubit.shouldShowSharedContacts,
        ColltactKind.colleague => colleaguesCubit.shouldShowColleagues,
      };

  ColltactTab _indexToTab(int index) => _tabs[index];

  int _tabToIndex(ColltactTab tab) => _tabs.indexOf(tab);
}

extension Mapping on List<ColltactTab> {
  List<Widget> widgets(Widget Function(ColltactTab tab) toWidget) =>
      map(toWidget).toList();
}