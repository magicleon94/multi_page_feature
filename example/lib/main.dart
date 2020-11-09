import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_page_feature/multi_page_feature.dart';

const FIRST_STEP_ROUTE_NAME = 'firstStep';
final navigationObserver = MultiPageFeatureNavigationObserver();
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi Page Feature Demo',
      home: Home(),
      navigatorObservers: [navigationObserver],
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demo'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Go!'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                settings: RouteSettings(name: FIRST_STEP_ROUTE_NAME),
                builder: (context) => MultiPageFeature(
                  blocCreate: (_) => MultiPageDemoBloc(),
                  navigationObserver: navigationObserver,
                  pages: [
                    FirstStepPage(),
                    SecondStepPage(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MultiPageDemoBloc extends MultiPageFeatureBloc {
  MultiPageDemoBloc() : super(First());

  @override
  Stream<MultiPageFeatureState> mapEventToState(
    MultiPageFeatureEvent event,
  ) async* {
    final state = handleEvent(event);
    if (state != null) {
      yield state;
    } else {
      switch (event.runtimeType) {
        case GenerateRandomText:
          final text = Random().nextInt(100).toString();
          yield RandomText(text);
          break;
        case GoToSecondStep:
          yield Second();
          break;
        case SecondStepCompleted:
          add(MultiPageFeatureFinished());
          break;
      }
    }
  }
}

class First extends PageChangingState {}

class Second extends PageChangingState {}

class RandomText extends MultiPageFeatureState {
  final String text;

  RandomText(this.text);
  @override
  List<Object> get props => [text];
}

class GenerateRandomText extends MultiPageFeatureEvent {}

class GoToSecondStep extends MultiPageFeatureEvent {}

class SecondStepCompleted extends MultiPageFeatureEvent {}

class FirstStepPage extends FeaturePage {
  @override
  bool get isInitialPage => true;

  @override
  String get name => FIRST_STEP_ROUTE_NAME;

  @override
  Widget pageBuilder(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First step'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<MultiPageFeatureBloc, MultiPageFeatureState>(
              buildWhen: (previous, current) => !(current is PageChangingState),
              builder: (context, state) {
                if (state.runtimeType == RandomText) {
                  return Text(
                    (state as RandomText).text ?? '-',
                  );
                } else {
                  return Text(state.toString());
                }
              },
            ),
            RaisedButton(
              child: Text('Update text'),
              onPressed: () {
                BlocProvider.of<MultiPageFeatureBloc>(context).add(
                  GenerateRandomText(),
                );
              },
            ),
            RaisedButton(
              child: Text('Next'),
              onPressed: () {
                BlocProvider.of<MultiPageFeatureBloc>(context).add(
                  GoToSecondStep(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Type get triggerState => First;
}

class SecondStepPage extends FeaturePage {
  @override
  bool get isInitialPage => false;

  @override
  String get name => 'secondStep';

  @override
  Widget pageBuilder(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second step'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Complete'),
          onPressed: () {
            BlocProvider.of<MultiPageFeatureBloc>(context).add(
              SecondStepCompleted(),
            );
          },
        ),
      ),
    );
  }

  @override
  Type get triggerState => Second;
}
