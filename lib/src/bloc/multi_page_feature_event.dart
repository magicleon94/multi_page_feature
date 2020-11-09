import 'package:equatable/equatable.dart';

abstract class MultiPageFeatureEvent extends Equatable {
  const MultiPageFeatureEvent();

  @override
  List<Object> get props => [];
}

///Used to tell the bloc we want to go back
class MultiPageFeatureBack extends MultiPageFeatureEvent {}

///Used to notify the bloc that a pop has happened
class MultiPageFeaturePagePopped extends MultiPageFeatureEvent {}

///Used to tell the bloc that the process has finished
class MultiPageFeatureFinished extends MultiPageFeatureEvent {}
