import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precision_vision/common/theme/app_typography.dart';
import 'package:precision_vision/settings/providers.dart';

class ModelSettingsScreen extends ConsumerWidget {
  const ModelSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentDetector = ref.watch(modelOrchestratorProvider);
    final notifier = ref.read(modelOrchestratorProvider.notifier);

    // Current model identifier (logic lives in the notifier so UI doesn't import detector classes)
    final currentModel = notifier.currentModel;

    final isYoloActive = currentModel == 'YOLOv8';
    final isMobileNetActive = currentModel == 'MobileNet';

    return Scaffold(
      backgroundColor: cs.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Available Models
            Text(
              'Available Models',
              style: PVTypography.labelCaps.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            _ModelCard(
              icon: Icons.speed,
              title: 'YOLOv8 (Fast)',
              subtitle: 'Optimized for real-time mobile tracking',
              isLoaded: isYoloActive,
              onLoad: isYoloActive ? null : notifier.changeToYoloV8,
              colorScheme: cs,
            ),
            const SizedBox(height: 12),
            _ModelCard(
              icon: Icons.light_mode,
              title: 'MobileNet v3 (Ultra Light)',
              subtitle: 'Minimal battery drain performance',
              isLoaded: isMobileNetActive,
              onLoad: isMobileNetActive ? null : notifier.changeToMobileNet,
              colorScheme: cs,
            ),
            const SizedBox(height: 12),
            _ModelCard(
              icon: Icons.biotech,
              title: 'EfficientDet (High Accuracy)',
              subtitle: 'Maximum precision for static objects',
              isLoaded: false,
              onLoad: null, // Not implemented yet
              colorScheme: cs,
            ),

            const SizedBox(height: 32),

            // Detection Settings
            Text(
              'Detection Settings',
              style: PVTypography.labelCaps.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh.withAlpha(100),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.outlineVariant.withAlpha(25)),
              ),
              child: Column(
                children: [
                  // Confidence Threshold
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Confidence Threshold',
                        style: PVTypography.bodyMd.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        currentDetector.confidenceThreshold.toStringAsFixed(2),
                        style: PVTypography.dataLg.copyWith(color: cs.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: currentDetector.confidenceThreshold,
                    onChanged: notifier.adjustConfidenceThreshold,
                    min: 0,
                    max: 1,
                    divisions: 100,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0.00',
                        style: PVTypography.dataSm.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '1.00',
                        style: PVTypography.dataSm.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Divider(color: cs.outlineVariant.withAlpha(50)),

                  // Toggles
                  const SizedBox(height: 16),
                  _ToggleRow(
                    icon: Icons.label,
                    label: 'Show Labels',
                    value: true,
                    colorScheme: cs,
                  ),
                  const SizedBox(height: 16),
                  _ToggleRow(
                    icon: Icons.dark_mode,
                    label: 'Dark Mode',
                    value: isDark,
                    colorScheme: cs,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLoaded;
  final ColorScheme colorScheme;
  final VoidCallback? onLoad;

  const _ModelCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isLoaded,
    required this.colorScheme,
    this.onLoad,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLoaded
            ? colorScheme.primaryContainer.withAlpha(25)
            : colorScheme.surfaceContainerHigh.withAlpha(100),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLoaded
              ? colorScheme.primary.withAlpha(80)
              : colorScheme.outlineVariant.withAlpha(25),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isLoaded
                  ? colorScheme.primary.withAlpha(50)
                  : colorScheme.surfaceContainerHighest.withAlpha(130),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isLoaded
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PVTypography.headlineSm.copyWith(
                    color: isLoaded
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: PVTypography.dataSm.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isLoaded)
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  'Loaded',
                  style: PVTypography.labelCaps.copyWith(
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            )
          else if (onLoad != null)
            TextButton(
              onPressed: onLoad,
              style: TextButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest.withAlpha(
                  130,
                ),
                foregroundColor: colorScheme.onSurface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Load', style: PVTypography.labelCaps),
            )
          else
            Text(
              'Soon',
              style: PVTypography.labelCaps.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ColorScheme colorScheme;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Text(
              label,
              style: PVTypography.bodyMd.copyWith(color: colorScheme.onSurface),
            ),
          ],
        ),
        Switch(value: value, onChanged: (_) {}),
      ],
    );
  }
}
