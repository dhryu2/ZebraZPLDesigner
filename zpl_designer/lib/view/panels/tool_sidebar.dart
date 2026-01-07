import 'package:flutter/material.dart';
import 'package:zpl_designer/core/app_theme.dart';
import 'package:zpl_designer/view/tools/tool_type.dart';

class ToolSidebar extends StatefulWidget {
  final Function(ToolType)? onToolDragStarted;

  const ToolSidebar({super.key, this.onToolDragStarted});

  @override
  State<ToolSidebar> createState() => _ToolSidebarState();
}

class _ToolSidebarState extends State<ToolSidebar> {
  ToolType? _selectedTool;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppTheme.leftPanelWidth,
      decoration: const BoxDecoration(
        color: AppTheme.bgSecondary,
        border: Border(
          right: BorderSide(color: AppTheme.surfaceBorder),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppTheme.spacingSm),
          _buildToolGroup([
            _ToolItem(ToolType.text, Icons.text_fields_outlined, 'Text'),
            _ToolItem(ToolType.box, Icons.crop_square_outlined, 'Box'),
            _ToolItem(ToolType.line, Icons.horizontal_rule, 'Line'),
            _ToolItem(ToolType.diagonal, Icons.show_chart, 'Diagonal'),
            _ToolItem(ToolType.circle, Icons.circle_outlined, 'Circle'),
            _ToolItem(ToolType.ellipse, Icons.panorama_fish_eye, 'Ellipse'),
          ]),
          const _Divider(),
          _buildToolGroup([
            _ToolItem(ToolType.barcode, Icons.view_week_outlined, 'Barcode'),
            _ToolItem(ToolType.qr, Icons.qr_code_2_outlined, 'QR Code'),
          ]),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildToolGroup(List<_ToolItem> items) {
    return Column(
      children: items.map((item) => _buildToolButton(item)).toList(),
    );
  }

  Widget _buildToolButton(_ToolItem item) {
    final isSelected = _selectedTool == item.type;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingXs,
        vertical: 2,
      ),
      child: Tooltip(
        message: item.tooltip,
        preferBelow: false,
        waitDuration: const Duration(milliseconds: 500),
        child: Draggable<ToolType>(
          data: item.type,
          onDragStarted: () {
            widget.onToolDragStarted?.call(item.type);
          },
          feedback: _buildDragFeedback(item),
          childWhenDragging: _buildButton(item, isSelected, isDragging: true),
          child: _buildButton(item, isSelected),
        ),
      ),
    );
  }

  Widget _buildButton(_ToolItem item, bool isSelected, {bool isDragging = false}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTool = _selectedTool == item.type ? null : item.type;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.accentPrimary.withOpacity(0.15)
                : isDragging
                    ? AppTheme.surfaceHover
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: isSelected
                ? Border.all(color: AppTheme.accentPrimary.withOpacity(0.5))
                : null,
          ),
          child: Icon(
            item.icon,
            size: 18,
            color: isSelected
                ? AppTheme.accentPrimary
                : isDragging
                    ? AppTheme.textTertiary
                    : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDragFeedback(_ToolItem item) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: AppTheme.bgElevated,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.accentPrimary),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 16, color: AppTheme.accentPrimary),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              item.type.name.toUpperCase(),
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolItem {
  final ToolType type;
  final IconData icon;
  final String tooltip;

  const _ToolItem(this.type, this.icon, this.tooltip);
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      height: 1,
      color: AppTheme.surfaceBorder,
    );
  }
}
