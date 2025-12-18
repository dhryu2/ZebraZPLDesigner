import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zpl_designer/core/app_theme.dart';
import 'package:zpl_designer/core/base_canvas_element.dart';
import 'package:zpl_designer/provider/editor_state_provider.dart';
import 'package:zpl_designer/view/item/barcode/barcode_canvas_element.dart';
import 'package:zpl_designer/view/item/box/box_canvas_element.dart';
import 'package:zpl_designer/view/item/line/line_canvas_element.dart';
import 'package:zpl_designer/view/item/qrcode/qrcode_canvas_element.dart';
import 'package:zpl_designer/view/item/text/text_canvas_element.dart';

class LayersPanel extends StatelessWidget {
  final List<BaseCanvasElement> elements;
  final Function(BaseCanvasElement)? onSelect;
  final Function(BaseCanvasElement)? onDelete;

  const LayersPanel({
    super.key,
    required this.elements,
    this.onSelect,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Sort by zIndex (highest first for visual order)
    final sortedElements = List<BaseCanvasElement>.from(elements)
      ..sort((a, b) => b.zIndex.compareTo(a.zIndex));

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgSecondary,
        border: Border(
          top: BorderSide(color: AppTheme.surfaceBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingSm,
            ),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.surfaceBorder),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.layers_outlined,
                  size: 14,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  'LAYERS',
                  style: AppTheme.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  '${elements.length}',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // Layer list
          Expanded(
            child: elements.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingXs,
                    ),
                    itemCount: sortedElements.length,
                    itemBuilder: (context, index) {
                      final element = sortedElements[index];
                      return _LayerItem(
                        element: element,
                        onTap: () => onSelect?.call(element),
                        onDelete: () => onDelete?.call(element),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_box_outlined,
              size: 24,
              color: AppTheme.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'No elements',
              style: AppTheme.caption.copyWith(
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LayerItem extends StatefulWidget {
  final BaseCanvasElement element;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _LayerItem({
    required this.element,
    this.onTap,
    this.onDelete,
  });

  @override
  State<_LayerItem> createState() => _LayerItemState();
}

class _LayerItemState extends State<_LayerItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorStateProvider>(
      builder: (context, state, child) {
        final isSelected = state.selectedElement == widget.element;

        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              margin: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingXs,
                vertical: 1,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSm,
                vertical: AppTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accentPrimary.withOpacity(0.15)
                    : _isHovered
                        ? AppTheme.surfaceHover
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: isSelected
                    ? Border.all(
                        color: AppTheme.accentPrimary.withOpacity(0.5),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.accentPrimary.withOpacity(0.2)
                          : AppTheme.bgTertiary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      _getIcon(),
                      size: 12,
                      color: isSelected
                          ? AppTheme.accentPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  // Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTypeName(),
                          style: AppTheme.bodySmall.copyWith(
                            color: isSelected
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                        Text(
                          _getDescription(),
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Delete button (on hover)
                  if (_isHovered || isSelected)
                    IconButton(
                      icon: const Icon(Icons.close, size: 14),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      color: AppTheme.textTertiary,
                      hoverColor: AppTheme.accentError.withOpacity(0.1),
                      onPressed: widget.onDelete,
                      tooltip: 'Delete',
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getIcon() {
    if (widget.element is TextCanvasElement) return Icons.text_fields_outlined;
    if (widget.element is BoxCanvasElement) return Icons.crop_square_outlined;
    if (widget.element is BarcodeCanvasElement) return Icons.view_week_outlined;
    if (widget.element is QRCodeCanvasElement) return Icons.qr_code_2_outlined;
    if (widget.element is LineCanvasElement) return Icons.horizontal_rule;
    return Icons.widgets_outlined;
  }

  String _getTypeName() {
    return widget.element.runtimeType.toString().replaceAll('CanvasElement', '');
  }

  String _getDescription() {
    final e = widget.element;
    if (e is TextCanvasElement) {
      return e.text.length > 20 ? '${e.text.substring(0, 20)}...' : e.text;
    }
    if (e is BarcodeCanvasElement) {
      return e.data;
    }
    if (e is QRCodeCanvasElement) {
      return e.data.length > 20 ? '${e.data.substring(0, 20)}...' : e.data;
    }
    return '${e.width}×${e.height} mm';
  }
}
