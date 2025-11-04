import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../data/dummy/dummy_in_app_messages.dart';
import '../../domain/models/in_app_message.dart';

class InAppMessagingController extends ChangeNotifier {
  InAppMessagingController({
    List<InAppBannerDefinition>? banners,
    List<InAppNudgeDefinition>? nudges,
  })  : _bannerDefinitions = <String, InAppBannerDefinition>{},
        _bannerStates = <String, _BannerState>{},
        _surfaceBanners = <MessageSurface, List<String>>{},
        _bannerNotifiers = <MessageSurface, ValueNotifier<List<InAppBannerDefinition>>>{},
        _nudgeDefinitions = <String, InAppNudgeDefinition>{},
        _nudgeStates = <String, _NudgeState>{},
        _surfaceNudges = <MessageSurface, List<String>>{},
        _nudgeNotifiers = <MessageSurface, ValueNotifier<InAppNudgeDefinition?>>{},
        _activeNudges = <String, MessageSurface>{},
        _snackController = StreamController<SnackMessage>.broadcast() {
    final resolvedBanners = banners ?? buildDefaultBanners();
    final resolvedNudges = nudges ?? buildDefaultNudges();
    for (final banner in resolvedBanners) {
      _bannerDefinitions[banner.id] = banner;
      _bannerStates[banner.id] = _BannerState(definition: banner);
      for (final surface in banner.surfaces) {
        _surfaceBanners.putIfAbsent(surface, () => <String>[]).add(banner.id);
        _bannerNotifiers.putIfAbsent(
          surface,
          () => ValueNotifier<List<InAppBannerDefinition>>(const <InAppBannerDefinition>[]),
        );
      }
    }
    for (final nudge in resolvedNudges) {
      _nudgeDefinitions[nudge.id] = nudge;
      _nudgeStates[nudge.id] = _NudgeState(definition: nudge);
      _surfaceNudges.putIfAbsent(nudge.surface, () => <String>[]).add(nudge.id);
      _nudgeNotifiers.putIfAbsent(
        nudge.surface,
        () => ValueNotifier<InAppNudgeDefinition?>(null),
      );
    }
  }

  final Map<String, InAppBannerDefinition> _bannerDefinitions;
  final Map<String, _BannerState> _bannerStates;
  final Map<MessageSurface, List<String>> _surfaceBanners;
  final Map<MessageSurface, ValueNotifier<List<InAppBannerDefinition>>> _bannerNotifiers;

  final Map<String, InAppNudgeDefinition> _nudgeDefinitions;
  final Map<String, _NudgeState> _nudgeStates;
  final Map<MessageSurface, List<String>> _surfaceNudges;
  final Map<MessageSurface, ValueNotifier<InAppNudgeDefinition?>> _nudgeNotifiers;
  final Map<String, MessageSurface> _activeNudges;

  final StreamController<SnackMessage> _snackController;
  bool _disposed = false;

  Stream<SnackMessage> get snackMessages => _snackController.stream;

  void activateSurface(MessageSurface surface) {
    if (_disposed) {
      return;
    }
    _updateBanners(surface);
    _maybeShowNudge(surface);
  }

  ValueListenable<List<InAppBannerDefinition>> bannersFor(MessageSurface surface) {
    return _ensureBannerNotifier(surface);
  }

  ValueListenable<InAppNudgeDefinition?> nudgeFor(MessageSurface surface) {
    return _ensureNudgeNotifier(surface);
  }

  void dismissBanner(String id) {
    final state = _bannerStates[id];
    if (state == null || state.dismissed) {
      return;
    }
    state.dismissed = true;
    for (final entry in _surfaceBanners.entries) {
      if (entry.value.contains(id)) {
        _updateBanners(entry.key);
      }
    }
  }

  String? handleBannerAction(String id) {
    final definition = _bannerDefinitions[id];
    if (definition == null) {
      return null;
    }
    if (definition.actionSnackKey != null) {
      _snackController.add(
        SnackMessage(
          key: definition.actionSnackKey!,
          params: definition.actionSnackParams,
        ),
      );
    }
    if (definition.actionId != null) {
      markActionCompleted(definition.actionId!);
    }
    return definition.actionRoute;
  }

  void dismissNudge(String id) {
    final surface = _activeNudges[id];
    if (surface != null) {
      final notifier = _ensureNudgeNotifier(surface);
      if (notifier.value?.id == id) {
        notifier.value = null;
      }
      _activeNudges.remove(id);
      _maybeShowNudge(surface);
    }
  }

  String? handleNudgeAction(String id) {
    final definition = _nudgeDefinitions[id];
    if (definition == null) {
      return null;
    }
    if (definition.actionSnackKey != null) {
      _snackController.add(
        SnackMessage(
          key: definition.actionSnackKey!,
          params: definition.actionSnackParams,
        ),
      );
    }
    dismissNudge(id);
    final state = _nudgeStates[id];
    if (state != null) {
      state.impressions = state.definition.maxImpressions;
    }
    if (definition.actionId != null) {
      markActionCompleted(definition.actionId!);
    }
    return definition.actionRoute;
  }

  void markActionCompleted(String actionId) {
    for (final entry in _nudgeStates.entries) {
      final state = entry.value;
      if (state.definition.actionId == actionId) {
        state.impressions = state.definition.maxImpressions;
        final surface = _activeNudges.remove(entry.key);
        if (surface != null) {
          final notifier = _ensureNudgeNotifier(surface);
          if (notifier.value?.id == state.definition.id) {
            notifier.value = null;
          }
        }
      }
    }
    for (final entry in _bannerStates.entries) {
      final state = entry.value;
      if (state.definition.actionId == actionId && !state.dismissed) {
        state.dismissed = true;
        for (final surfaceEntry in _surfaceBanners.entries) {
          if (surfaceEntry.value.contains(state.definition.id)) {
            _updateBanners(surfaceEntry.key);
          }
        }
      }
    }
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    for (final notifier in _bannerNotifiers.values) {
      notifier.dispose();
    }
    for (final notifier in _nudgeNotifiers.values) {
      notifier.dispose();
    }
    _snackController.close();
    super.dispose();
  }

  ValueNotifier<List<InAppBannerDefinition>> _ensureBannerNotifier(MessageSurface surface) {
    return _bannerNotifiers.putIfAbsent(
      surface,
      () => ValueNotifier<List<InAppBannerDefinition>>(const <InAppBannerDefinition>[]),
    );
  }

  ValueNotifier<InAppNudgeDefinition?> _ensureNudgeNotifier(MessageSurface surface) {
    return _nudgeNotifiers.putIfAbsent(
      surface,
      () => ValueNotifier<InAppNudgeDefinition?>(null),
    );
  }

  void _updateBanners(MessageSurface surface) {
    final notifier = _ensureBannerNotifier(surface);
    final ids = _surfaceBanners[surface];
    if (ids == null || ids.isEmpty) {
      notifier.value = const <InAppBannerDefinition>[];
      return;
    }
    final visible = <InAppBannerDefinition>[];
    for (final id in ids) {
      final state = _bannerStates[id];
      if (state == null || state.dismissed) {
        continue;
      }
      visible.add(state.definition);
    }
    notifier.value = List<InAppBannerDefinition>.unmodifiable(visible);
  }

  void _maybeShowNudge(MessageSurface surface) {
    final notifier = _ensureNudgeNotifier(surface);
    final ids = _surfaceNudges[surface];
    if (ids == null || ids.isEmpty) {
      notifier.value = null;
      return;
    }
    final now = DateTime.now();
    for (final id in ids) {
      final state = _nudgeStates[id];
      if (state == null) {
        continue;
      }
      final definition = state.definition;
      if (state.impressions >= definition.maxImpressions) {
        continue;
      }
      final lastShown = state.lastShown;
      if (lastShown != null && now.difference(lastShown) < definition.minInterval) {
        continue;
      }
      if (_activeNudges[id] == surface && notifier.value?.id == id) {
        return;
      }
      notifier.value = definition;
      state.lastShown = now;
      state.impressions += 1;
      _activeNudges[id] = surface;
      return;
    }
    notifier.value = null;
  }
}

class _BannerState {
  _BannerState({required this.definition});

  final InAppBannerDefinition definition;
  bool dismissed = false;
}

class _NudgeState {
  _NudgeState({required this.definition});

  final InAppNudgeDefinition definition;
  int impressions = 0;
  DateTime? lastShown;
}

class InAppMessagingScope extends InheritedNotifier<InAppMessagingController> {
  const InAppMessagingScope({
    super.key,
    required InAppMessagingController controller,
    required super.child,
  }) : super(notifier: controller);

  static InAppMessagingController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InAppMessagingScope>()?.notifier;
  }
}
