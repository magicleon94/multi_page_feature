import 'dart:async';

import 'package:flutter/widgets.dart';

class PopEvent {}

class MultiPageFeatureNavigationObserver extends NavigatorObserver {
  final _routeStack = <Route<dynamic>>[];
  final _popStreamController = StreamController<PopEvent>.broadcast();
  Stream<PopEvent> get popStream => _popStreamController.stream;

  ///Get the `Route` which is on top of the navigation stack
  Route get topOfStack =>
      (_routeStack?.isNotEmpty ?? false) ? _routeStack.last : null;

  ///Get the `Route` below the one which is currently on top of the navigation stack
  Route get routeBeforeTopOfStack => (_routeStack?.length ?? 0) >= 2
      ? _routeStack.elementAt(_routeStack.length - 2)
      : null;

  ///Get the `Route` below the one with the specified [name] in the navigation stack.
  Route getRouteBefore(String name) {
    final index =
        _routeStack.indexWhere((route) => route.settings.name == name);
    if (index > 0) {
      return _routeStack[index - 1];
    } else {
      return null;
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    _routeStack.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    _routeStack.removeLast();
    _popStreamController.sink.add(PopEvent());
  }

  @override
  void didRemove(Route route, Route previousRoute) {
    _routeStack.remove(route);
  }

  @override
  void didReplace({Route newRoute, Route oldRoute}) {
    _routeStack.removeLast();
    _routeStack.add(newRoute);
  }

  ///Get a `Route` by its [name]. Returns null if nothing was found in the navigation stack.
  Route getByName(String name) {
    return _routeStack.firstWhere((r) => r.settings.name == name,
        orElse: () => null);
  }

  ///Check wether a route with the specified [name] exists in the navigation stack or not
  bool isInStack(String name) {
    return _routeStack.any(
      (r) => r.settings?.name == name,
    );
  }

  ///Dispose the observer and close its [popStream]
  void dispose() {
    _popStreamController?.close();
  }
}
