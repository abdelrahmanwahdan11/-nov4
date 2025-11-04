import 'package:flutter/material.dart';

enum MessageSurface {
  menu,
  catalog,
  cart,
  mealPlanner,
  compare,
  settings,
}

enum InAppBannerTone {
  info,
  positive,
  warning,
}

class InAppActionIds {
  InAppActionIds._();

  static const String openCatalog = 'open_catalog';
  static const String openMealPlanner = 'open_meal_planner';
  static const String openCompareTables = 'open_compare_tables';
  static const String focusCartPromo = 'focus_cart_promo';
}

class SnackMessage {
  const SnackMessage({required this.key, this.params});

  final String key;
  final Map<String, dynamic>? params;
}

@immutable
class InAppBannerDefinition {
  const InAppBannerDefinition({
    required this.id,
    required this.surfaces,
    required this.titleKey,
    required this.messageKey,
    this.tone = InAppBannerTone.info,
    this.actionLabelKey,
    this.actionRoute,
    this.actionSnackKey,
    this.actionSnackParams,
    this.actionId,
  });

  final String id;
  final Set<MessageSurface> surfaces;
  final String titleKey;
  final String messageKey;
  final InAppBannerTone tone;
  final String? actionLabelKey;
  final String? actionRoute;
  final String? actionSnackKey;
  final Map<String, dynamic>? actionSnackParams;
  final String? actionId;
}

@immutable
class InAppNudgeDefinition {
  const InAppNudgeDefinition({
    required this.id,
    required this.surface,
    required this.titleKey,
    required this.messageKey,
    this.actionLabelKey,
    this.actionRoute,
    this.actionSnackKey,
    this.actionSnackParams,
    this.actionId,
    this.maxImpressions = 1,
    this.minInterval = const Duration(minutes: 2),
  });

  final String id;
  final MessageSurface surface;
  final String titleKey;
  final String messageKey;
  final String? actionLabelKey;
  final String? actionRoute;
  final String? actionSnackKey;
  final Map<String, dynamic>? actionSnackParams;
  final String? actionId;
  final int maxImpressions;
  final Duration minInterval;
}
