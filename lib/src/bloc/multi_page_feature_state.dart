import 'package:equatable/equatable.dart';

abstract class MultiPageFeatureState extends Equatable {
  const MultiPageFeatureState();

  @override
  List<Object> get props => [runtimeType];
}

///[PageChangingState] is the type of state that triggers a navigation
abstract class PageChangingState extends MultiPageFeatureState {}

///[MultiPageFeatureQuit] is the state that tells that it's time to quit the process.
class MultiPageFeatureQuit extends PageChangingState {}
