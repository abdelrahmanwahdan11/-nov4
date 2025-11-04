import 'package:flutter/widgets.dart';

class ChangeNotifierProvider<T extends ChangeNotifier> extends StatefulWidget {
  const ChangeNotifierProvider({
    super.key,
    required this.create,
    required this.child,
  });

  final T Function(BuildContext context) create;
  final Widget child;

  @override
  State<ChangeNotifierProvider<T>> createState() => _ChangeNotifierProviderState<T>();
}

class _ChangeNotifierProviderState<T extends ChangeNotifier> extends State<ChangeNotifierProvider<T>> {
  late final T _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = widget.create(context);
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedNotifier<T>(
      notifier: _notifier,
      child: widget.child,
    );
  }
}

class _InheritedNotifier<T extends Listenable> extends InheritedNotifier<T> {
  const _InheritedNotifier({
    required T notifier,
    required super.child,
  }) : super(notifier: notifier);

  T get exposedNotifier => notifier!;
}

class Consumer<T extends ChangeNotifier> extends StatelessWidget {
  const Consumer({
    super.key,
    required this.builder,
    this.child,
  });

  final Widget? child;
  final Widget Function(BuildContext context, T notifier, Widget? child) builder;

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<T>();
    return builder(context, notifier, child);
  }
}

class Consumer2<A extends ChangeNotifier, B extends ChangeNotifier> extends StatelessWidget {
  const Consumer2({
    super.key,
    required this.builder,
    this.child,
  });

  final Widget? child;
  final Widget Function(BuildContext context, A first, B second, Widget? child) builder;

  @override
  Widget build(BuildContext context) {
    final first = context.watch<A>();
    final second = context.watch<B>();
    return builder(context, first, second, child);
  }
}

extension SimpleProviderContext on BuildContext {
  T watch<T extends ChangeNotifier>() {
    final inherited = dependOnInheritedWidgetOfExactType<_InheritedNotifier<T>>();
    if (inherited == null) {
      throw FlutterError('No ChangeNotifierProvider found for type $T');
    }
    return inherited.exposedNotifier;
  }

  T read<T extends ChangeNotifier>() {
    final element = getElementForInheritedWidgetOfExactType<_InheritedNotifier<T>>();
    if (element == null) {
      throw FlutterError('No ChangeNotifierProvider found for type $T');
    }
    final widget = element.widget as _InheritedNotifier<T>;
    return widget.exposedNotifier;
  }
}
