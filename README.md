## What? And why?
The package is based on the [flutter_bloc](https://pub.dev/packages/flutter_bloc) implementation of the BLoC pattern and its goal is to help organizing multi page features in a Flutter application by providing useful interfaces that help implement each page independently.

The main goal of this independence is that the pages **will not** have the need to handle navigation decisions. This will allow an higher degree of flexibility in the development process since changing the flow order would require only a modification in the bloc and will leave untouched the screens. Same goes for chosing one way or another when pushing the new route. The bloc will decide everything.

## Components

### MultiPageFeatureBloc
The base class for Blocs that will handle the state of a multi page feature.
When overriding it, be sure to call `handleEvent` as the first thing of your `mapEventToState` method: 
this will handle the `MultiPageFeatureBack` and `MultiPageFeaturePagePopped` events and react accordingly updating the navigations and the `pageChangingStatesHistory`.

### MultiPageFeatureEvent(s)
By default the following events are implemented:
- `MultiPageFeatureBack`: used by the widgets to tell the bloc that we want to go back in navigation.
- `MultiPageFeaturePagePopped`: used to tell the bloc that a `pop` was done (when swiping back from iOS or via the hardware Android button, for example)
- `MultiPageFeatureFinished`: used to signal the bloc that the process of the feature has come to an end.

### MultiPageFeatureState(s)
By default the following events are implemented:
- `PageChangingState`: abstraction used to identify the kind of event that triggers a navigation update.
- `MultiPageFeatureQuit`: used by the bloc to signal that the process will be quit.

### FeaturePage
The single page of the feature. Each feature must inherit from this.
Each feature has:
- a `name` to identify the route. 
- a `isInitialPage` parameter which tells that this page is the first of the process.
- a `triggerState` which tells that this page should be pushed in navigation when the state occurs
- a `pageBuilder` which builds the page
- a `pageRouteBuilder` which can be used to optionally customise the built route. By default `MaterialPageRoute` is built.

**Important notes**<br>
At least one feature page **must** have `isInitialPage` set to true.
The initial feature page **must** have the same `name` as the route used to push `MultiPageFeature`.

### MultiPageFeatureNavigationObserver
An implementation of Flutter's `NavigatorObserver` needed to know the navigation stack situation in order to manipulate it during the process.

### MultiPageFeature
The UI component which reacts to the `PageChangingState` to manage navigation and informs the bloc if a `pop` was performed.

The constructor takes the following arguments:
- `blocCreate`: a function that builds the designed bloc. If a bloc is returned by using `blocCreate`, it will be disposed along the `MultiPageFeature` disposal.
- `blocValue`: the bloc to use for the feature. If a bloc is provided via `blocValue` it **will not** be disposed along the `MultiPageFeature` disposal.
- `navigationObserver`: the same `MultiPageFeatureNavigationObserver` instance passed to the current `Navigator`. This is usually passed to `navigatorObservers` in `MaterialApp`.
- `pages`: a list of `FeaturePage` implementation

## Usage
1. Create an implementation of `MultiPageFeatureBloc`
2. Create the needed implementations of states and events by extending `MultiPageFeatureEvent` and `MultiPageFeatureState`, keeping in mind that page changing states should extend `PageChangingState` instead.
3. Create the needed implementations of `FeaturePage`, one for each process step.
4. Pass everything to the `MultiPageFeature` widget when beginning the process.

You can have a more concrete idea in the example!

### Footnotes
#### Why didn't you use a nested navigator?
The first implementation used Navigator 2.0 and a nested navigation, which allowed a very smooth implementation of everything. Unfortunately, Flutter has a problem with nested navigation: when nesting navigators, the swipe to back iOS gesture doesn't work as expected, since it'll pop the whole nested navigator and not the route of the nested navigator.
#### I use named routes in my app, why should I need this?
I use named routes and `onGenerateRoute` too, and I've made a good utility to clean the process of managing named routes [route_handler](https://pub.dev/packages/route_handler). <br>
The thing is that most times your main app navigator couldn't care less of managing named routes which are just steps of a process, so the idea is to avoid all that clutter but mantaining a better structure than "randomly" pushing routes from the UI code.

_**This is, for now, an experiment. The package might prove itself useful or a total mess, be aware of this and feel free to provide some feedback**_