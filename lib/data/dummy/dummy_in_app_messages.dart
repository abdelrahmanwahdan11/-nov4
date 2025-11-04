import '../../domain/models/in_app_message.dart';

List<InAppBannerDefinition> buildDefaultBanners() {
  return <InAppBannerDefinition>[
    InAppBannerDefinition(
      id: 'seasonal_combos',
      surfaces: const {MessageSurface.menu, MessageSurface.catalog},
      titleKey: 'banner_seasonal_title',
      messageKey: 'banner_seasonal_message',
      tone: InAppBannerTone.positive,
      actionLabelKey: 'banner_seasonal_action',
      actionRoute: '/catalog',
      actionSnackKey: 'banner_seasonal_toast',
      actionId: InAppActionIds.openCatalog,
    ),
    InAppBannerDefinition(
      id: 'meal_planner',
      surfaces: const {MessageSurface.menu, MessageSurface.cart},
      titleKey: 'banner_planner_title',
      messageKey: 'banner_planner_message',
      tone: InAppBannerTone.info,
      actionLabelKey: 'banner_planner_action',
      actionRoute: '/meal-planner',
      actionSnackKey: 'banner_planner_toast',
      actionId: InAppActionIds.openMealPlanner,
    ),
    InAppBannerDefinition(
      id: 'compare_tables',
      surfaces: const {MessageSurface.menu},
      titleKey: 'banner_compare_title',
      messageKey: 'banner_compare_message',
      tone: InAppBannerTone.warning,
      actionLabelKey: 'banner_compare_action',
      actionRoute: '/compare/tables',
      actionSnackKey: 'banner_compare_toast',
      actionId: InAppActionIds.openCompareTables,
    ),
  ];
}

List<InAppNudgeDefinition> buildDefaultNudges() {
  return <InAppNudgeDefinition>[
    const InAppNudgeDefinition(
      id: 'menu_meal_planner',
      surface: MessageSurface.menu,
      titleKey: 'nudge_planner_title',
      messageKey: 'nudge_planner_message',
      actionLabelKey: 'nudge_planner_action',
      actionRoute: '/meal-planner',
      actionSnackKey: 'nudge_planner_toast',
      actionId: InAppActionIds.openMealPlanner,
      maxImpressions: 1,
      minInterval: Duration(minutes: 5),
    ),
    const InAppNudgeDefinition(
      id: 'cart_promo_hint',
      surface: MessageSurface.cart,
      titleKey: 'nudge_promo_title',
      messageKey: 'nudge_promo_message',
      actionLabelKey: 'nudge_promo_action',
      actionSnackKey: 'nudge_promo_toast',
      actionId: InAppActionIds.focusCartPromo,
      maxImpressions: 2,
      minInterval: Duration(minutes: 3),
    ),
  ];
}
