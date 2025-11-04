import 'package:flutter/material.dart';

import 'app_controller.dart';

enum TutorialTarget {
  searchBar,
  addToCart,
  darkToggle,
  colorPicker,
}

class TutorialController extends ChangeNotifier {
  TutorialController({required this.appController});

  final AppController appController;

  final ValueNotifier<TutorialTarget?> currentTarget =
      ValueNotifier<TutorialTarget?>(null);

  final Map<TutorialTarget, GlobalKey> _anchors =
      <TutorialTarget, GlobalKey>{};

  final List<TutorialTarget> _sequence = const <TutorialTarget>[
    TutorialTarget.searchBar,
    TutorialTarget.addToCart,
    TutorialTarget.darkToggle,
    TutorialTarget.colorPicker,
  ];

  bool _isActive = false;
  final Set<TutorialTarget> _visitedTargets = <TutorialTarget>{};

  bool get isActive => _isActive;

  List<TutorialTarget> get sequence => List.unmodifiable(_sequence);

  void registerAnchor(TutorialTarget target, GlobalKey key) {
    _anchors[target] = key;
    if (_isActive && currentTarget.value == target) {
      notifyListeners();
    }
  }

  void unregisterAnchor(TutorialTarget target, GlobalKey key) {
    final existing = _anchors[target];
    if (existing == key) {
      _anchors.remove(target);
    }
  }

  GlobalKey? anchorOf(TutorialTarget target) => _anchors[target];

  void startIfNeeded() {
    _start(force: false);
  }

  void start() {
    _start(force: true);
  }

  void _start({required bool force}) {
    if (_isActive) {
      return;
    }
    if (!force && !appController.firstRun) {
      return;
    }
    _visitedTargets.clear();
    _isActive = true;
    _selectTarget(_sequence.first);
  }

  void next() {
    if (!_isActive) {
      return;
    }
    final target = currentTarget.value;
    if (target == null) {
      return;
    }
    final index = _sequence.indexOf(target);
    if (index == -1 || index >= _sequence.length - 1) {
      complete();
      return;
    }
    _selectTarget(_sequence[index + 1]);
  }

  void skip() {
    if (!_isActive) {
      return;
    }
    _isActive = false;
    currentTarget.value = null;
    _visitedTargets.clear();
    notifyListeners();
  }

  Future<void> complete() async {
    if (!_isActive) {
      return;
    }
    _isActive = false;
    currentTarget.value = null;
    final hasSeenAll = _sequence.every(_visitedTargets.contains);
    if (hasSeenAll) {
      await appController.markFirstRunComplete();
    }
    _visitedTargets.clear();
    notifyListeners();
  }

  Future<void> restart() async {
    await appController.resetFirstRun();
    _isActive = false;
    currentTarget.value = null;
    notifyListeners();
    _start(force: true);
  }

  @override
  void dispose() {
    currentTarget.dispose();
    super.dispose();
  }

  void _selectTarget(TutorialTarget target) {
    currentTarget.value = target;
    _visitedTargets.add(target);
    notifyListeners();
  }
}

class TutorialScope extends InheritedNotifier<TutorialController> {
  const TutorialScope({
    super.key,
    required super.child,
    required TutorialController controller,
  }) : super(notifier: controller);

  static TutorialController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TutorialScope>()?.notifier;
  }

  static TutorialController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'TutorialScope not found in context');
    return controller!;
  }
}
