import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zpl_designer/core/app_theme.dart';
import 'package:zpl_designer/core/base_canvas_element.dart';
import 'package:zpl_designer/provider/canvas_config_provider.dart';
import 'package:zpl_designer/provider/editor_state_provider.dart';

enum ZIndexAction {
  bringToFront,
  bringForward,
  sendBackward,
  sendToBack,
}

abstract class BaseCanvasItem<T extends BaseCanvasElement>
    extends StatefulWidget {
  final T canvasElement;
  final VoidCallback onRemove;
  final void Function(int x, int y)? onPositionChanged;
  final void Function(int width, int height)? onSizeChanged;
  final void Function(ZIndexAction action)? onZIndexChanged;
  final VoidCallback? onSelected;
  final double pixelsPerMm;

  const BaseCanvasItem({
    super.key,
    required this.canvasElement,
    required this.onRemove,
    required this.onPositionChanged,
    this.onSizeChanged,
    this.onZIndexChanged,
    this.onSelected,
    this.pixelsPerMm = 1.0,
  });
}

enum _ResizeDirection {
  topLeft,
  top,
  topRight,
  left,
  right,
  bottomLeft,
  bottom,
  bottomRight,
}

abstract class BaseCanvasItemState<
  W extends BaseCanvasItem<E>,
  E extends BaseCanvasElement
>
    extends State<W> {
  bool _hovering = false;
  bool _isResizing = false;
  bool _isDragging = false;

  E get element => widget.canvasElement;

  bool get _isActive => _hovering || _isResizing || _isDragging;

  int get minWidth => 5;
  int get minHeight => 5;

  Widget renderElement(BuildContext context);

  List<PropertyItem> addEditPropertyItems();

  bool _isSelected(BuildContext context) {
    final editorState = context.watch<EditorStateProvider>();
    return editorState.selectedElement == element;
  }

  void _selectElement() {
    widget.onSelected?.call();
  }

  void showContextMenu(TapDownDetails details) async {
    _selectElement();

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        details.globalPosition.dx + 1,
        details.globalPosition.dy + 1,
      ),
      color: AppTheme.bgElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        side: const BorderSide(color: AppTheme.surfaceBorder),
      ),
      items: [
        _buildMenuItem('bringToFront', Icons.flip_to_front, 'Bring to Front'),
        _buildMenuItem('bringForward', Icons.arrow_upward, 'Bring Forward'),
        _buildMenuItem('sendBackward', Icons.arrow_downward, 'Send Backward'),
        _buildMenuItem('sendToBack', Icons.flip_to_back, 'Send to Back'),
        const PopupMenuDivider(),
        _buildMenuItem('duplicate', Icons.copy_outlined, 'Duplicate'),
        const PopupMenuDivider(),
        _buildMenuItem('remove', Icons.delete_outline, 'Delete', isDestructive: true),
      ],
    );

    if (selected == 'remove') {
      widget.onRemove();
    } else if (selected == 'bringToFront') {
      widget.onZIndexChanged?.call(ZIndexAction.bringToFront);
    } else if (selected == 'bringForward') {
      widget.onZIndexChanged?.call(ZIndexAction.bringForward);
    } else if (selected == 'sendBackward') {
      widget.onZIndexChanged?.call(ZIndexAction.sendBackward);
    } else if (selected == 'sendToBack') {
      widget.onZIndexChanged?.call(ZIndexAction.sendToBack);
    } else if (selected == 'duplicate') {
      // TODO: Implement duplicate
    }
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String label, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDestructive ? AppTheme.accentError : AppTheme.textSecondary,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: isDestructive ? AppTheme.accentError : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _onPositionUpdate(DragUpdateDetails details, BuildContext context) {
    final canvasConfig = context.read<CanvasConfigProvider>();
    final canvasWidth = canvasConfig.widthMm;
    final canvasHeight = canvasConfig.heightMm;

    final maxX = (canvasWidth - element.width).clamp(0, canvasWidth);
    final maxY = (canvasHeight - element.height).clamp(0, canvasHeight);

    final deltaMmX = details.delta.dx / widget.pixelsPerMm;
    final deltaMmY = details.delta.dy / widget.pixelsPerMm;

    final newX = (element.x + deltaMmX).round().clamp(0, maxX);
    final newY = (element.y + deltaMmY).round().clamp(0, maxY);
    widget.onPositionChanged?.call(newX, newY);
  }

  void _onResizeUpdate(DragUpdateDetails details, _ResizeDirection direction) {
    final canvasConfig = context.read<CanvasConfigProvider>();
    final canvasWidth = canvasConfig.widthMm;
    final canvasHeight = canvasConfig.heightMm;

    int newX = element.x;
    int newY = element.y;
    int newWidth = element.width;
    int newHeight = element.height;

    final dx = (details.delta.dx / widget.pixelsPerMm).round();
    final dy = (details.delta.dy / widget.pixelsPerMm).round();

    switch (direction) {
      case _ResizeDirection.topLeft:
        newX += dx;
        newY += dy;
        newWidth -= dx;
        newHeight -= dy;
        break;
      case _ResizeDirection.top:
        newY += dy;
        newHeight -= dy;
        break;
      case _ResizeDirection.topRight:
        newY += dy;
        newWidth += dx;
        newHeight -= dy;
        break;
      case _ResizeDirection.left:
        newX += dx;
        newWidth -= dx;
        break;
      case _ResizeDirection.right:
        newWidth += dx;
        break;
      case _ResizeDirection.bottomLeft:
        newX += dx;
        newWidth -= dx;
        newHeight += dy;
        break;
      case _ResizeDirection.bottom:
        newHeight += dy;
        break;
      case _ResizeDirection.bottomRight:
        newWidth += dx;
        newHeight += dy;
        break;
    }

    if (newWidth < minWidth) {
      if (direction == _ResizeDirection.left ||
          direction == _ResizeDirection.topLeft ||
          direction == _ResizeDirection.bottomLeft) {
        newX = element.x + element.width - minWidth;
      }
      newWidth = minWidth;
    }
    if (newHeight < minHeight) {
      if (direction == _ResizeDirection.top ||
          direction == _ResizeDirection.topLeft ||
          direction == _ResizeDirection.topRight) {
        newY = element.y + element.height - minHeight;
      }
      newHeight = minHeight;
    }

    if (newX < 0) newX = 0;
    if (newY < 0) newY = 0;

    if (newX + newWidth > canvasWidth) {
      if (direction == _ResizeDirection.right ||
          direction == _ResizeDirection.topRight ||
          direction == _ResizeDirection.bottomRight) {
        newWidth = canvasWidth - newX;
      } else {
        newX = canvasWidth - newWidth;
      }
    }

    if (newY + newHeight > canvasHeight) {
      if (direction == _ResizeDirection.bottom ||
          direction == _ResizeDirection.bottomLeft ||
          direction == _ResizeDirection.bottomRight) {
        newHeight = canvasHeight - newY;
      } else {
        newY = canvasHeight - newHeight;
      }
    }

    if (newWidth < minWidth) newWidth = minWidth;
    if (newHeight < minHeight) newHeight = minHeight;

    setState(() {
      element.x = newX;
      element.y = newY;
      element.resize(newWidth, newHeight);
    });

    widget.onPositionChanged?.call(newX, newY);
    widget.onSizeChanged?.call(newWidth, newHeight);
  }

  List<Widget> _buildResizeHandles(bool isSelected) {
    const double size = 8;
    const double halfSize = size / 2;

    Widget buildHandle(_ResizeDirection direction, {
      double? left,
      double? right,
      double? top,
      double? bottom,
      required MouseCursor cursor,
    }) {
      return Positioned(
        left: left,
        right: right,
        top: top,
        bottom: bottom,
        child: MouseRegion(
          cursor: cursor,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (_) => setState(() => _isResizing = true),
            onPanUpdate: (details) => _onResizeUpdate(details, direction),
            onPanEnd: (_) => setState(() => _isResizing = false),
            onPanCancel: () => setState(() => _isResizing = false),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: AppTheme.accentPrimary,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return [
      buildHandle(
        _ResizeDirection.topLeft,
        left: -halfSize,
        top: -halfSize,
        cursor: SystemMouseCursors.resizeUpLeft,
      ),
      buildHandle(
        _ResizeDirection.topRight,
        right: -halfSize,
        top: -halfSize,
        cursor: SystemMouseCursors.resizeUpRight,
      ),
      buildHandle(
        _ResizeDirection.bottomLeft,
        left: -halfSize,
        bottom: -halfSize,
        cursor: SystemMouseCursors.resizeDownLeft,
      ),
      buildHandle(
        _ResizeDirection.bottomRight,
        right: -halfSize,
        bottom: -halfSize,
        cursor: SystemMouseCursors.resizeDownRight,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = _isSelected(context);
    final showHandles = isSelected || _isActive;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _selectElement,
      onSecondaryTapDown: showContextMenu,
      onPanStart: (_) {
        _selectElement();
        setState(() => _isDragging = true);
      },
      onPanUpdate: (details) {
        _onPositionUpdate(details, context);
      },
      onPanEnd: (_) => setState(() => _isDragging = false),
      onPanCancel: () => setState(() => _isDragging = false),
      child: MouseRegion(
        cursor: _isActive ? SystemMouseCursors.move : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.accentPrimary
                        : _hovering
                            ? AppTheme.accentPrimary.withOpacity(0.5)
                            : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.accentPrimary.withOpacity(0.25),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : _hovering
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                ),
                child: ClipRect(child: renderElement(context)),
              ),
            ),
            if (showHandles) ..._buildResizeHandles(isSelected),
          ],
        ),
      ),
    );
  }
}

class PropertyItem {
  PropertyItem({required this.propertyWidget, required this.saveProperty});

  Widget propertyWidget;
  VoidCallback saveProperty;
}
