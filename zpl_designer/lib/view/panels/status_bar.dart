import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zpl_designer/core/app_theme.dart';
import 'package:zpl_designer/provider/canvas_config_provider.dart';
import 'package:zpl_designer/provider/editor_state_provider.dart';

class StatusBar extends StatelessWidget {
  final int elementCount;

  const StatusBar({
    super.key,
    required this.elementCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTheme.statusBarHeight,
      decoration: const BoxDecoration(
        color: AppTheme.bgTertiary,
        border: Border(
          top: BorderSide(color: AppTheme.surfaceBorder),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        child: Row(
          children: [
            // Element info
            _buildElementInfo(context),
            const Spacer(),
            // Canvas info
            _buildCanvasInfo(context),
            const _StatusDivider(),
            // DPMM info
            _buildDpmmInfo(context),
            const _StatusDivider(),
            // Element count
            _buildElementCount(),
          ],
        ),
      ),
    );
  }

  Widget _buildElementInfo(BuildContext context) {
    return Consumer<EditorStateProvider>(
      builder: (context, state, child) {
        final element = state.selectedElement;

        if (element == null) {
          return Text(
            'Ready',
            style: AppTheme.caption.copyWith(color: AppTheme.textTertiary),
          );
        }

        final typeName = element.runtimeType.toString().replaceAll('CanvasElement', '');

        return Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppTheme.accentPrimary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              typeName,
              style: AppTheme.caption.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Text(
              'X: ${element.x}  Y: ${element.y}  W: ${element.width}  H: ${element.height}',
              style: AppTheme.caption.copyWith(color: AppTheme.textTertiary),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCanvasInfo(BuildContext context) {
    return Consumer<CanvasConfigProvider>(
      builder: (context, config, child) {
        return _StatusItem(
          icon: Icons.crop_square_outlined,
          label: '${config.widthMm} × ${config.heightMm} mm',
        );
      },
    );
  }

  Widget _buildDpmmInfo(BuildContext context) {
    return Consumer<CanvasConfigProvider>(
      builder: (context, config, child) {
        return _StatusItem(
          icon: Icons.grain,
          label: '${config.dpmm.value} dpmm',
        );
      },
    );
  }

  Widget _buildElementCount() {
    return _StatusItem(
      icon: Icons.layers_outlined,
      label: '$elementCount element${elementCount != 1 ? 's' : ''}',
    );
  }
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: AppTheme.textTertiary,
        ),
        const SizedBox(width: AppTheme.spacingXs),
        Text(
          label,
          style: AppTheme.caption.copyWith(color: AppTheme.textTertiary),
        ),
      ],
    );
  }
}

class _StatusDivider extends StatelessWidget {
  const _StatusDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      color: AppTheme.surfaceBorder,
    );
  }
}
