import 'package:flutter/material.dart' hide NavigationDestination;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../domain/entities/navigation_destination.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../widgets/header.dart';
import 'cubit.dart';

class NavigationDrawer extends StatefulWidget {
  final Function(NavigationDestination) onNavigate;

  const NavigationDrawer({required this.onNavigate});

  @override
  State<StatefulWidget> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  void onNavigationPressed(
    BuildContext context,
    NavigationState state,
    NavigationDestination navigation,
  ) {
    final cubit = context.read<NavigationCubit>();

    // User is attempting to edit navigation rather than navigation somewhere
    if (state is NavigationUnlocked) {
      cubit.addSelectedDestination(navigation);
      return;
    }

    Navigator.pop(context);
    widget.onNavigate(navigation);
  }

  @override
  void initState() {
    super.initState();
    // Always make sure navigation is locked when opening it.
    context.read<NavigationCubit>().lock();
  }

  void _logout() async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(context.msg.main.logout.confirm.title),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.msg.main.logout.title),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.msg.generic.button.cancel),
              ),
            ],
          );
        });

    if (confirmed == true) {
      context.read<NavigationCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NavigationCubit, NavigationState>(
      builder: (context, state) {
        final cubit = context.read<NavigationCubit>();

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Drawer(
            width: MediaQuery.of(context).size.width,
            semanticLabel: context.msg.main.navigation.drawer.title,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 40,
                bottom: 10,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavigationDrawerHeader(
                    onCloseButtonPressed: Navigator.of(context).pop,
                    onEditButtonPressed:
                        state is NavigationLocked ? cubit.unlock : cubit.lock,
                    isUnlocked: state is NavigationUnlocked,
                  ),
                  const Divider(),
                  Expanded(
                    child: _NavigationDrawerGrid(
                      selected: state.selected,
                      isEditable: state is NavigationUnlocked,
                      onNavigationPressed: (navigation) => onNavigationPressed(
                        context,
                        state,
                        navigation,
                      ),
                      navigation: NavigationDestination.values
                          .where(
                            (e) => !const [
                              NavigationDestination.logout,
                              NavigationDestination.feedback,
                            ].contains(e),
                          )
                          .toList(),
                      lowerNavigationItems: [
                        _NavigationDrawerGridItem(
                          NavigationDestination.feedback,
                          onPressed: () => onNavigationPressed(
                            context,
                            state,
                            NavigationDestination.feedback,
                          ),
                        ),
                        _NavigationDrawerGridItem(
                          NavigationDestination.logout,
                          onPressed: _logout,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      listener: (context, state) {
        if (state is! NavigationTooManySelected &&
            state is! NavigationTooFewSelected) {
          return;
        }

        showModalBottomSheet(
          context: context,
          builder: (context) {
            Future.delayed(const Duration(seconds: 3), () {
              Navigator.pop(context);
            });

            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 8,
              ),
              child: Text(
                state is NavigationTooManySelected
                    ? context.msg.main.navigation.drawer.tooMany
                    : context.msg.main.navigation.drawer.tooFew,
                textAlign: TextAlign.center,
              ),
            );
          },
        );
      },
    );
  }
}

class _NavigationDrawerHeader extends StatelessWidget {
  final VoidCallback onEditButtonPressed;
  final VoidCallback onCloseButtonPressed;
  final bool isUnlocked;

  const _NavigationDrawerHeader({
    required this.onEditButtonPressed,
    required this.onCloseButtonPressed,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Header(
            context.msg.main.navigation.drawer.title,
            padding: const EdgeInsets.all(0),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onEditButtonPressed,
                icon: FaIcon(
                  isUnlocked
                      ? FontAwesomeIcons.lockOpen
                      : FontAwesomeIcons.lock,
                  color: context.brand.theme.colors.grey6,
                ),
              ),
              IconButton(
                onPressed: onCloseButtonPressed,
                icon: FaIcon(
                  FontAwesomeIcons.xmark,
                  color: context.brand.theme.colors.grey6,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class _NavigationDrawerGrid extends StatelessWidget {
  final List<NavigationDestination> navigation;
  final List<NavigationDestination> selected;
  final List<Widget> lowerNavigationItems;
  final bool isEditable;
  final Function(NavigationDestination) onNavigationPressed;

  const _NavigationDrawerGrid({
    required this.navigation,
    required this.selected,
    required this.onNavigationPressed,
    required this.lowerNavigationItems,
    this.isEditable = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (isEditable)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              child: Container(
                color: context.brand.theme.colors.grey3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  child: Column(
                    children: [
                      Text(
                        context.msg.main.navigation.drawer.unlock,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          GridView.count(
            childAspectRatio: 1.2,
            padding: const EdgeInsets.only(top: 14),
            crossAxisCount: 3,
            mainAxisSpacing: 0,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ...navigation.map(
                (destination) => _NavigationDrawerGridItem(
                  destination,
                  isEditable: isEditable,
                  isSelected: selected.contains(destination),
                  isHome: destination == selected.first,
                  onPressed: () => onNavigationPressed(destination),
                ),
              ),
            ],
          ),
          if (!isEditable)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ).copyWith(
                top: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: lowerNavigationItems,
              ),
            ),
        ],
      ),
    );
  }
}

class _NavigationDrawerGridItem extends StatelessWidget {
  final NavigationDestination navigationDestination;
  final VoidCallback? onPressed;

  /// The item that will be rendered with an icon indicating that this is the
  /// home destination.
  final bool isHome;

  /// If the item should appear as editable, this will include a bookmark
  /// icon that is greyed out.
  final bool isEditable;

  /// If the item is currently one of the selected items, render an icon to
  /// display this.
  final bool isSelected;

  final double editIconSize = 16;

  const _NavigationDrawerGridItem(
    this.navigationDestination, {
    this.onPressed,
    this.isHome = false,
    this.isSelected = false,
    this.isEditable = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: GridTile(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: editIconSize),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavigationDestinationIcon(navigationDestination),
                const SizedBox(height: 16),
                Text(navigationDestination.asLabel(context)),
              ],
            ),
            _SelectedNavigationDestinationIcon(
              isHome ? FontAwesomeIcons.house : FontAwesomeIcons.solidBookmark,
              isEditable: isEditable,
              isSelected: isSelected,
              size: editIconSize,
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedNavigationDestinationIcon extends StatelessWidget {
  final double size;
  final bool isEditable;
  final bool isSelected;
  final IconData icon;

  const _SelectedNavigationDestinationIcon(
    this.icon, {
    required this.isEditable,
    required this.isSelected,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (isEditable || isSelected) {
      return FaIcon(
        icon,
        size: size,
        color: isSelected ? context.brand.theme.colors.primary : Colors.grey,
      );
    }

    return SizedBox(width: size);
  }
}

class _NavigationDestinationIcon extends StatelessWidget {
  final NavigationDestination destination;

  const _NavigationDestinationIcon(this.destination);

  @override
  Widget build(BuildContext context) {
    return FaIcon(
      destination.asIconData(),
      size: 32,
      color: context.brand.theme.colors.grey6,
      semanticLabel: destination.asLabel(context),
    );
  }
}

extension NavigationDestinationWidgetData on NavigationDestination {
  IconData asIconData() {
    switch (this) {
      case NavigationDestination.dialer:
        return VialerSans.dialpad;
      case NavigationDestination.contacts:
        return VialerSans.contacts;
      case NavigationDestination.recents:
        return VialerSans.clock;
      case NavigationDestination.settings:
        return VialerSans.settings;
      case NavigationDestination.logout:
        return VialerSans.logout;
      case NavigationDestination.calls:
        return FontAwesomeIcons.boxArchive;
      case NavigationDestination.dialPlan:
        return FontAwesomeIcons.retweet;
      case NavigationDestination.stats:
        return FontAwesomeIcons.chartColumn;
      case NavigationDestination.feedback:
        return VialerSans.feedback;
      case NavigationDestination.telephony:
        return FontAwesomeIcons.arrowsSplitUpAndLeft;
    }
  }

  String asLabel(BuildContext context) {
    switch (this) {
      case NavigationDestination.dialer:
        return context.msg.main.dialer.menu.title;
      case NavigationDestination.contacts:
        return context.msg.main.contacts.menu.title;
      case NavigationDestination.recents:
        return context.msg.main.recent.menu.title;
      case NavigationDestination.settings:
        return context.msg.main.settings.menu.title;
      case NavigationDestination.logout:
        return context.msg.main.logout.title;
      case NavigationDestination.calls:
        return context.msg.main.calls.title;
      case NavigationDestination.dialPlan:
        return context.msg.main.dialPlan.title;
      case NavigationDestination.stats:
        return context.msg.main.stats.title;
      case NavigationDestination.feedback:
        return context.msg.main.feedback.title;
      case NavigationDestination.telephony:
        return context.msg.main.telephony.title;
    }
  }
}
