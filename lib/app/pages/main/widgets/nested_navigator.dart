import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef WidgetWithArgumentsBuilder = Widget Function(BuildContext, Object?);

class NestedNavigator extends StatefulWidget {
  /// Can be used to manipulate the [Navigator] directly.
  final GlobalKey<NavigatorState>? navigatorKey;

  final String initialRoute;
  final Map<String, WidgetWithArgumentsBuilder> routes;

  /// This is only used on the root [NestedNavigator], it's ignored for
  /// descendants.
  final Future<bool> Function() onWillPop;

  final List<NavigatorObserver> observers;

  /// Passed to [MaterialPageRoute.fullscreenDialog]. Applies to all routes.
  final bool fullscreenDialog;

  /// Sibling [NestedNavigator]s are not supported. It's always assumed that
  /// a [NestedNavigator] that's added to the widget tree is a descendant of
  /// the already existing [NestedNavigator]s.
  NestedNavigator({
    Key? key,
    this.navigatorKey,

    /// If kept `null`, the first entry in [routes] is used.
    String? initialRoute,
    required this.routes,
    Future<bool> Function()? onWillPop,
    this.observers = const [],
    this.fullscreenDialog = false,
  })  : initialRoute = initialRoute ?? routes.keys.first,
        onWillPop = onWillPop ?? (() => SynchronousFuture(true)),
        super(key: key);

  @override
  _NestedNavigatorState createState() => _NestedNavigatorState();
}

class _NestedNavigatorState extends State<NestedNavigator> {
  final _heroController = MaterialApp.createMaterialHeroController();

  late final GlobalKey<NavigatorState> _navigatorKey;

  _NestedNavigatorState? __rootNestedNavigatorState;

  _NestedNavigatorState? get _rootNestedNavigatorState =>
      __rootNestedNavigatorState ??=
          Provider.of<_NestedNavigatorState?>(context, listen: false);

  bool get _hasRootNestedNavigator => _rootNestedNavigatorState != null;

  _NestedNavigatorState get _rootNestedNavigatorStateOrThis =>
      _rootNestedNavigatorState ?? this;

  bool _initialized = false;
  final _navigatorsToPop = <GlobalKey<NavigatorState>>[];

  // Since the nested navigator cannot capture the back button press (Android),
  // we use WillPopScope to capture that event, and pop the nested navigator
  // route if possible.
  Future<bool> _onWillPop() {
    for (final navigatorKey in _navigatorsToPop.reversed) {
      final state = navigatorKey.currentState!;
      if (state.canPop()) {
        state.pop();
        return SynchronousFuture(false);
      }
    }

    return widget.onWillPop();
  }

  @override
  void initState() {
    super.initState();
    _navigatorKey = widget.navigatorKey ?? GlobalKey<NavigatorState>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _rootNestedNavigatorStateOrThis._navigatorsToPop.add(_navigatorKey);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = HeroControllerScope(
      controller: _heroController,
      child: Navigator(
        key: _navigatorKey,
        initialRoute: widget.initialRoute,
        observers: widget.observers,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            settings: settings,
            fullscreenDialog: widget.fullscreenDialog,
            builder: (context) {
              return widget.routes[settings.name]!(context, settings.arguments);
            },
          );
        },
      ),
    );

    if (_hasRootNestedNavigator) {
      return result;
    } else {
      // Only a single WillPopScope in the widget tree works, this is why we
      // add the navigator states to pop to the root NestedNavigator.
      return Provider<_NestedNavigatorState>.value(
        value: this,
        child: WillPopScope(
          onWillPop: _onWillPop,
          child: result,
        ),
      );
    }
  }

  @override
  void dispose() {
    __rootNestedNavigatorState?._navigatorsToPop.remove(_navigatorKey);
    super.dispose();
  }
}
