import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'multi_page_feature_event.dart';
import 'multi_page_feature_state.dart';

abstract class MultiPageFeatureBloc
    extends Bloc<MultiPageFeatureEvent, MultiPageFeatureState> {
  final _pageChangingStatesHistory = <PageChangingState>[];

  MultiPageFeatureBloc(PageChangingState initialState) : super(initialState) {
    _pageChangingStatesHistory.add(initialState);
  }

  List<MultiPageFeatureState> get pageChangingStatesHistory =>
      List.from(_pageChangingStatesHistory);

  ///Manages the back or pop events and updates the `PageChangingState` history
  ///If `null` this means the event needs to be managed by the inheriting bloc.
  @protected
  MultiPageFeatureState handleEvent(MultiPageFeatureEvent event) {
    if (event is MultiPageFeatureBack || event is MultiPageFeaturePagePopped) {
      if (_pageChangingStatesHistory.length > 1) {
        _pageChangingStatesHistory.removeLast();
        return _pageChangingStatesHistory.last;
      } else {
        if (event is MultiPageFeatureBack) {
          return MultiPageFeatureQuit();
        }
      }
    }
    if (event is MultiPageFeatureFinished) {
      return MultiPageFeatureQuit();
    }
    return null;
  }

  @override
  void onTransition(
      Transition<MultiPageFeatureEvent, MultiPageFeatureState> transition) {
    if (!(transition.event is MultiPageFeatureBack)) {
      if (transition.nextState is PageChangingState &&
          !_stateInHistory(transition.nextState)) {
        _pageChangingStatesHistory.add(transition.nextState);
      }
    }
    super.onTransition(transition);
  }

  ///For efficiency purposes. This is like `contains` but proceeds in reversed order
  bool _stateInHistory(MultiPageFeatureState state) {
    for (var i = _pageChangingStatesHistory.length - 1; i >= 0; i--) {
      final item = _pageChangingStatesHistory[i];
      if (item == state) {
        return true;
      }
    }
    return false;
  }
}
