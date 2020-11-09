import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/multi_page_feature_bloc.dart';

abstract class FeaturePage {
  ///The [name] of the route. This is needed to correctly manipulate the navigation stack
  String get name;

  ///The state type that triggers the push of this page onto the navigation stack
  Type get triggerState;

  ///Wether this is the initial page or not
  bool get isInitialPage;

  ///The builder for the page
  Widget pageBuilder(BuildContext context);

  ///Override this to get a different route builder for custom transitions or other things
  Route pageRouteBuilder(BuildContext context, MultiPageFeatureBloc bloc) =>
      MaterialPageRoute(
        settings: RouteSettings(
          name: name,
        ),
        builder: (context) => BlocProvider.value(
          value: bloc,
          child: Builder(builder: (ctx) => pageBuilder(ctx)),
        ),
      );
}
