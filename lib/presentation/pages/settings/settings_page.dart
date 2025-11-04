import 'package:flutter/material.dart';

import '../../../core/locale/localization_extension.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/tutorial_controller.dart';
import '../../widgets/tutorial_overlay.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.controller});

  static const routeName = '/settings';

  final AppController controller;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _presetColors = <Color>[
    ThemeTokens.seedPrimary,
    Color(0xFF0EA5E9),
    Color(0xFFF97316),
    Color(0xFF6366F1),
    Color(0xFFE11D48),
    Color(0xFF14B8A6),
  ];

  late final ValueNotifier<Color> _previewColor;
  late final VoidCallback _controllerListener;

  @override
  void initState() {
    super.initState();
    _previewColor = ValueNotifier<Color>(widget.controller.primarySeed);
    _controllerListener = () {
      _previewColor.value = widget.controller.primarySeed;
    };
    widget.controller.addListener(_controllerListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerListener);
    _previewColor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('settings_title')),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final tutorialController = TutorialScope.maybeOf(context);

          final themeTiles = ThemeMode.values.map((mode) {
            Widget tile = RadioListTile<ThemeMode>(
              value: mode,
              groupValue: controller.themeMode,
              onChanged: (value) {
                if (value != null) {
                  controller.setThemeMode(value);
                }
              },
              title: Text(_labelForThemeMode(context, mode)),
            );
            if (mode == ThemeMode.dark) {
              tile = TutorialTargetAnchor(
                target: TutorialTarget.darkToggle,
                child: tile,
              );
            }
            return tile;
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                context.tr('settings_theme_section'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...themeTiles,
              const SizedBox(height: 16),
              Text(
                context.tr('settings_language_section'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Locale>(
                value: controller.locale ?? const Locale('en'),
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text('English')),
                  DropdownMenuItem(value: Locale('ar'), child: Text('العربية')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.setLocale(value);
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('settings_layout_section'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: true,
                    icon: const Icon(Icons.grid_view_rounded),
                    label: Text(context.tr('settings_layout_grid')),
                  ),
                  ButtonSegment(
                    value: false,
                    icon: const Icon(Icons.view_agenda_outlined),
                    label: Text(context.tr('settings_layout_list')),
                  ),
                ],
                selected: {controller.catalogGridMode.value},
                onSelectionChanged: (selection) {
                  final selected = selection.first;
                  controller.setCatalogGridMode(selected);
                },
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('settings_density_section'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SegmentedButton<ContentDensity>(
                segments: [
                  ButtonSegment(
                    value: ContentDensity.comfortable,
                    icon: const Icon(Icons.view_comfy_alt),
                    label: Text(context.tr('settings_density_comfortable')),
                  ),
                  ButtonSegment(
                    value: ContentDensity.compact,
                    icon: const Icon(Icons.view_compact_alt),
                    label: Text(context.tr('settings_density_compact')),
                  ),
                ],
                selected: {controller.contentDensity.value},
                onSelectionChanged: (selection) {
                  controller.setContentDensity(selection.first);
                },
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('settings_density_hint'),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('settings_color_section'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _presetColors
                    .map(
                      (color) => _ColorChoice(
                        color: color,
                        selected: color.value == controller.primarySeed.value,
                        onTap: () {
                          controller.setPrimarySeed(color);
                          _previewColor.value = color;
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<Color>(
                valueListenable: _previewColor,
                builder: (context, color, _) {
                  final hexValue = color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.tr('settings_color_preview_title'),
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  context.tr('settings_color_preview_subtitle'),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '#$hexValue',
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ),
                          TutorialTargetAnchor(
                            target: TutorialTarget.colorPicker,
                            child: FilledButton.tonalIcon(
                              onPressed: () => _openColorPicker(context),
                              icon: const Icon(Icons.palette_outlined),
                              label:
                                  Text(context.tr('settings_color_picker_cta')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                context.tr('settings_connection_section'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SegmentedButton<ConnectionOverride>(
                segments: [
                  ButtonSegment(
                    value: ConnectionOverride.normal,
                    icon: const Icon(Icons.wifi),
                    label: Text(context.tr('settings_connection_online')),
                  ),
                  ButtonSegment(
                    value: ConnectionOverride.offline,
                    icon: const Icon(Icons.wifi_off),
                    label: Text(context.tr('settings_connection_offline')),
                  ),
                  ButtonSegment(
                    value: ConnectionOverride.error,
                    icon: const Icon(Icons.error_outline),
                    label: Text(context.tr('settings_connection_error')),
                  ),
                ],
                selected: {controller.connectionOverride.value},
                onSelectionChanged: (selection) {
                  final selected = selection.first;
                  controller.setConnectionOverride(selected);
                },
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('settings_connection_hint'),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              if (tutorialController != null) ...[
                const SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.refresh),
                    title:
                        Text(context.tr('settings_tutorial_restart_title')),
                    subtitle: Text(
                      context.tr('settings_tutorial_restart_subtitle'),
                    ),
                    onTap: () async {
                      await tutorialController.restart();
                      if (!mounted) {
                        return;
                      }
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _labelForThemeMode(BuildContext context, ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => context.tr('settings_theme_system'),
      ThemeMode.light => context.tr('settings_theme_light'),
      ThemeMode.dark => context.tr('settings_theme_dark'),
    };
  }

  Future<void> _openColorPicker(BuildContext context) async {
    final controller = widget.controller;
    final baseColor = HSVColor.fromColor(controller.primarySeed);
    final hueNotifier = ValueNotifier<double>(baseColor.hue);
    final saturationNotifier = ValueNotifier<double>(baseColor.saturation);
    final valueNotifier = ValueNotifier<double>(baseColor.value);

    Color compose() {
      return HSVColor.fromAHSV(
        1,
        hueNotifier.value.clamp(0, 360),
        saturationNotifier.value.clamp(0, 1),
        valueNotifier.value.clamp(0, 1),
      ).toColor();
    }

    final previewNotifier = ValueNotifier<Color>(compose());
    void listener() {
      previewNotifier.value = compose();
    }

    hueNotifier.addListener(listener);
    saturationNotifier.addListener(listener);
    valueNotifier.addListener(listener);

    final selectedColor = await showDialog<Color>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.tr('settings_color_picker_title')),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<Color>(
                  valueListenable: previewNotifier,
                  builder: (context, color, _) {
                    return Container(
                      height: 72,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _ColorSlider(
                  label: context.tr('settings_color_picker_hue'),
                  notifier: hueNotifier,
                  min: 0,
                  max: 360,
                  divisions: 36,
                ),
                _ColorSlider(
                  label: context.tr('settings_color_picker_saturation'),
                  notifier: saturationNotifier,
                  min: 0,
                  max: 1,
                ),
                _ColorSlider(
                  label: context.tr('settings_color_picker_brightness'),
                  notifier: valueNotifier,
                  min: 0,
                  max: 1,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.tr('settings_color_picker_cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(previewNotifier.value),
              child: Text(context.tr('settings_color_picker_apply')),
            ),
          ],
        );
      },
    );

    hueNotifier
      ..removeListener(listener)
      ..dispose();
    saturationNotifier
      ..removeListener(listener)
      ..dispose();
    valueNotifier
      ..removeListener(listener)
      ..dispose();
    previewNotifier.dispose();

    if (selectedColor != null) {
      await controller.setPrimarySeed(selectedColor);
      _previewColor.value = selectedColor;
    }
  }
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.onPrimary : Colors.transparent,
            width: 3,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

class _ColorSlider extends StatelessWidget {
  const _ColorSlider({
    required this.label,
    required this.notifier,
    required this.min,
    required this.max,
    this.divisions,
  });

  final String label;
  final ValueNotifier<double> notifier;
  final double min;
  final double max;
  final int? divisions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ValueListenableBuilder<double>(
        valueListenable: notifier,
        builder: (context, value, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    value.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: (newValue) {
                  if (newValue != value) {
                    notifier.value = newValue;
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// PHASE_5_DONE
