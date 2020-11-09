import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_page_feature/src/feature_page.dart';
import 'package:multi_page_feature/src/multi_page_feature_navigation_observer.dart';

import 'bloc/multi_page_feature_bloc.dart';
import 'bloc/multi_page_feature_event.dart';
import 'bloc/multi_page_feature_state.dart';

class MultiPageFeature extends StatefulWidget {
  ///A function which creates the needed bloc.
  ///The bloc will be disposed when [MultiPageFeature] will be disposed.
  final MultiPageFeatureBloc Function(BuildContext) blocCreate;

  ///The bloc to use for the feature.
  ///Passing a bloc here will not cause it to be disposed upon [MultiPageFeature] disposal.
  final MultiPageFeatureBloc blocValue;

  ///The same observer of the currently used `Navigator`.
  ///Tipically this is passed to `navigatorObservers` in `MaterialApp`.
  final MultiPageFeatureNavigationObserver navigationObserver;

  ///The [pages] of the feature
  final List<FeaturePage> pages;

  const MultiPageFeature({
    Key key,
    this.blocCreate,
    this.blocValue,
    @required this.navigationObserver,
    this.pages = const [],
  })  : assert(
          blocCreate != null || blocValue != null,
          'Provider either a blocCreate or a blocValue!',
        ),
        super(key: key);
  @override
  _MultiPageFeatureState createState() => _MultiPageFeatureState();
}

class _MultiPageFeatureState extends State<MultiPageFeature> {
  NavigatorState get navigator => Navigator.of(context);
  MultiPageFeatureBloc bloc;
  StreamSubscription subscription;
  @override
  void didChangeDependencies() {
    bloc ??= widget.blocValue ?? widget.blocCreate(context);
    subscription ??= widget.navigationObserver.popStream.listen(onPop);
    super.didChangeDependencies();
  }

  void onPop(PopEvent popEvent) {
    bloc.add(MultiPageFeaturePagePopped());
  }

  @override
  void dispose() {
    if (widget.blocCreate != null) {
      bloc.close();
    }
    subscription?.cancel();
    super.dispose();
  }

  void quitFeature() {
    final initialPage = widget.pages.firstWhere((page) => page.isInitialPage);

    final routeToPop =
        widget.navigationObserver.getRouteBefore(initialPage.name);

    while (widget.navigationObserver.routeBeforeTopOfStack.settings.name !=
        routeToPop.settings.name) {
      navigator.removeRouteBelow(widget.navigationObserver.topOfStack);
    }
    navigator.pop();
  }

  void pageChangingStateListener(
      BuildContext context, MultiPageFeatureState state) {
    if (state.runtimeType == MultiPageFeatureQuit) {
      subscription.cancel();
      quitFeature();
      return;
    }

    final triggeredPage = widget.pages
        .firstWhere((page) => page.triggerState == state.runtimeType);

    if (widget.navigationObserver.isInStack(triggeredPage.name)) {
      if (widget.navigationObserver.topOfStack.settings.name !=
          triggeredPage.name) {
        navigator.popUntil(
          ModalRoute.withName(triggeredPage.name),
        );
      }
    } else {
      Navigator.of(context).push(
        triggeredPage.pageRouteBuilder(context, bloc),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MultiPageFeatureBloc>.value(
      value: bloc,
      child: Builder(
        builder: (context) =>
            BlocListener<MultiPageFeatureBloc, MultiPageFeatureState>(
          listenWhen: (previous, current) => current is PageChangingState,
          listener: pageChangingStateListener,
          child: widget.pages
              .firstWhere((page) => page.isInitialPage)
              .pageBuilder(context),
        ),
      ),
    );
  }
}
