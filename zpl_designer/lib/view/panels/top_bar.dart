import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zpl_designer/core/app_theme.dart';
import 'package:zpl_designer/provider/canvas_config_provider.dart';
import 'package:zpl_designer/provider/editor_state_provider.dart';

class TopBar extends StatelessWidget {
  final VoidCallback? onImport;
  final VoidCallback? onExport;
  final VoidCallback? onPreview;
  final bool hasElements;

  const TopBar({
    super.key,
    this.onImport,
    this.onExport,
    this.onPreview,
    this.hasElements = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTheme.topBarHeight,
      decoration: const BoxDecoration(
        color: AppTheme.bgSecondary,
        border: Border(
          bottom: BorderSide(color: AppTheme.surfaceBorder),
        ),
      ),
      child: Row(
        children: [
          // Logo/Title
          _buildTitle(),
          const _VerticalDivider(),
          // File actions
          _buildFileActions(),
          const _VerticalDivider(),
          // Edit actions
          _buildEditActions(context),
          const Spacer(),
          // Zoom controls
          _buildZoomControls(context),
          const _VerticalDivider(),
          // View options
          _buildViewOptions(context),
          const SizedBox(width: AppTheme.spacingSm),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.accentPrimary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.label_outline,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          const Text(
            'ZPL Designer',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
      child: Row(
        children: [
          _ActionButton(
            icon: Icons.file_upload_outlined,
            tooltip: 'Import ZPL',
            onPressed: onImport,
          ),
          _ActionButton(
            icon: Icons.file_download_outlined,
            tooltip: 'Export ZPL',
            onPressed: hasElements ? onExport : null,
          ),
          _ActionButton(
            icon: Icons.visibility_outlined,
            tooltip: 'Preview',
            onPressed: hasElements ? onPreview : null,
          ),
        ],
      ),
    );
  }

  Widget _buildEditActions(BuildContext context) {
    return Consumer<EditorStateProvider>(
      builder: (context, state, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
          child: Row(
            children: [
              _ActionButton(
                icon: Icons.undo,
                tooltip: 'Undo (Ctrl+Z)',
                onPressed: state.canUndo ? () => state.undo() : null,
              ),
              _ActionButton(
                icon: Icons.redo,
                tooltip: 'Redo (Ctrl+Y)',
                onPressed: state.canRedo ? () => state.redo() : null,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildZoomControls(BuildContext context) {
    return Consumer<EditorStateProvider>(
      builder: (context, state, child) {
        final zoomPercent = (state.zoom * 100).round();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
          child: Row(
            children: [
              _ActionButton(
                icon: Icons.remove,
                tooltip: 'Zoom Out',
                onPressed: state.zoom > EditorStateProvider.minZoom
                    ? () => state.zoomOut()
                    : null,
                small: true,
              ),
              Container(
                width: 50,
                alignment: Alignment.center,
                child: Text(
                  '$zoomPercent%',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              _ActionButton(
                icon: Icons.add,
                tooltip: 'Zoom In',
                onPressed: state.zoom < EditorStateProvider.maxZoom
                    ? () => state.zoomIn()
                    : null,
                small: true,
              ),
              const SizedBox(width: AppTheme.spacingXs),
              _ActionButton(
                icon: Icons.fit_screen_outlined,
                tooltip: 'Fit to Screen',
                onPressed: () => state.resetZoom(),
                small: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildViewOptions(BuildContext context) {
    return Consumer<CanvasConfigProvider>(
      builder: (context, config, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
          child: Row(
            children: [
              _ActionButton(
                icon: config.showGrid ? Icons.grid_on : Icons.grid_off,
                tooltip: config.showGrid ? 'Hide Grid' : 'Show Grid',
                onPressed: () => config.toggleGrid(),
                isActive: config.showGrid,
                small: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isActive;
  final bool small;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.isActive = false,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: Container(
            width: small ? 28 : 32,
            height: small ? 28 : 32,
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.accentPrimary.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(
              icon,
              size: small ? 16 : 18,
              color: isDisabled
                  ? AppTheme.textDisabled
                  : isActive
                      ? AppTheme.accentPrimary
                      : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXs),
      color: AppTheme.surfaceBorder,
    );
  }
}
