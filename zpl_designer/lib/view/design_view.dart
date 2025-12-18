import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zpl_designer/core/app_theme.dart';
import 'package:zpl_designer/core/base_canvas_element.dart';
import 'package:zpl_designer/core/base_canvas_item.dart';
import 'package:zpl_designer/provider/canvas_config_provider.dart';
import 'package:zpl_designer/provider/editor_state_provider.dart';
import 'package:zpl_designer/view/item/barcode/barcode_canvas_element.dart';
import 'package:zpl_designer/view/item/barcode/barcode_canvas_widget.dart';
import 'package:zpl_designer/view/item/box/box_canvas_element.dart';
import 'package:zpl_designer/view/item/box/box_canvas_widget.dart';
import 'package:zpl_designer/view/item/line/line_canvas_element.dart';
import 'package:zpl_designer/view/item/line/line_canvas_widget.dart';
import 'package:zpl_designer/view/item/qrcode/qrcode_canvas_element.dart';
import 'package:zpl_designer/view/item/qrcode/qrcode_canvas_widget.dart';
import 'package:zpl_designer/view/item/text/text_canvas_element.dart';
import 'package:zpl_designer/view/item/text/text_canvas_widget.dart';
import 'package:zpl_designer/view/panels/layers_panel.dart';
import 'package:zpl_designer/view/panels/properties_panel.dart';
import 'package:zpl_designer/view/panels/status_bar.dart';
import 'package:zpl_designer/view/panels/tool_sidebar.dart';
import 'package:zpl_designer/view/panels/top_bar.dart';
import 'package:zpl_designer/view/tools/tool_type.dart';
import 'package:zpl_designer/view/widget/canvas_grid.dart';
import 'package:zpl_designer/view/widget/zpl_export_dialog.dart';
import 'package:zpl_designer/view/widget/zpl_import_dialog.dart';
import 'package:zpl_designer/view/widget/zpl_preview_dialog.dart';

class DesignView extends StatefulWidget {
  const DesignView({super.key});

  @override
  createState() => DesignViewState();
}

class DesignViewState extends State<DesignView> {
  final List<BaseCanvasElement> elements = [];
  final FocusNode _focusNode = FocusNode();

  int? _lastCanvasWidth;
  int? _lastCanvasHeight;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  int _getNextZIndex() {
    if (elements.isEmpty) return 0;
    return elements.map((e) => e.zIndex).reduce((a, b) => a > b ? a : b) + 1;
  }

  void _adjustElementsToCanvas(int canvasWidth, int canvasHeight) {
    if (elements.isEmpty) return;

    bool needsUpdate = false;

    for (final element in elements) {
      int newX = element.x;
      int newY = element.y;
      int newWidth = element.width;
      int newHeight = element.height;

      if (newWidth > canvasWidth) {
        newWidth = canvasWidth;
        needsUpdate = true;
      }
      if (newHeight > canvasHeight) {
        newHeight = canvasHeight;
        needsUpdate = true;
      }

      final maxX = (canvasWidth - newWidth).clamp(0, canvasWidth);
      final maxY = (canvasHeight - newHeight).clamp(0, canvasHeight);

      if (newX > maxX) {
        newX = maxX;
        needsUpdate = true;
      }
      if (newY > maxY) {
        newY = maxY;
        needsUpdate = true;
      }

      if (newWidth < 5) newWidth = 5;
      if (newHeight < 5) newHeight = 5;

      element.x = newX;
      element.y = newY;
      element.width = newWidth;
      element.height = newHeight;
    }

    if (needsUpdate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showSnackBar('Elements adjusted to fit canvas');
        }
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTheme.bodySmall.copyWith(color: Colors.white)),
        backgroundColor: AppTheme.bgElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        margin: const EdgeInsets.all(AppTheme.spacingMd),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addElement(ToolType type, int x, int y) {
    final config = context.read<CanvasConfigProvider>();
    late final BaseCanvasElement newElement;

    switch (type) {
      case ToolType.text:
        newElement = _createTextElement(x, y);
        break;
      case ToolType.box:
        newElement = _createBoxElement(x, y);
        break;
      case ToolType.barcode:
        newElement = _createBarcodeElement(x, y);
        break;
      case ToolType.qr:
        newElement = _createQRCodeElement(x, y);
        break;
      case ToolType.line:
        newElement = _createLineElement(x, y);
        break;
    }

    final maxX = (config.widthMm - newElement.width).clamp(0, config.widthMm);
    final maxY = (config.heightMm - newElement.height).clamp(0, config.heightMm);
    newElement.x = newElement.x.clamp(0, maxX);
    newElement.y = newElement.y.clamp(0, maxY);
    newElement.zIndex = _getNextZIndex();

    setState(() {
      elements.add(newElement);
    });

    // Select the new element
    context.read<EditorStateProvider>().selectElement(newElement);
  }

  void _removeElement(BaseCanvasElement element) {
    final editorState = context.read<EditorStateProvider>();
    if (editorState.selectedElement == element) {
      editorState.clearSelection();
    }
    setState(() {
      elements.remove(element);
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final editorState = context.read<EditorStateProvider>();
    final isCtrl = HardwareKeyboard.instance.isControlPressed;

    // Delete selected element
    if (event.logicalKey == LogicalKeyboardKey.delete ||
        event.logicalKey == LogicalKeyboardKey.backspace) {
      final selected = editorState.selectedElement;
      if (selected != null) {
        _removeElement(selected);
      }
    }

    // Undo/Redo
    if (isCtrl && event.logicalKey == LogicalKeyboardKey.keyZ) {
      editorState.undo();
    }
    if (isCtrl && event.logicalKey == LogicalKeyboardKey.keyY) {
      editorState.redo();
    }

    // Escape to deselect
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      editorState.clearSelection();
    }
  }

  void _handleZIndexChange(BaseCanvasElement element, ZIndexAction action) {
    setState(() {
      final sortedElements = List<BaseCanvasElement>.from(elements)
        ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

      final currentIndex = sortedElements.indexOf(element);

      switch (action) {
        case ZIndexAction.bringToFront:
          element.zIndex = _getNextZIndex();
          break;
        case ZIndexAction.bringForward:
          if (currentIndex < sortedElements.length - 1) {
            final aboveElement = sortedElements[currentIndex + 1];
            final tempZIndex = element.zIndex;
            element.zIndex = aboveElement.zIndex;
            aboveElement.zIndex = tempZIndex;
          }
          break;
        case ZIndexAction.sendBackward:
          if (currentIndex > 0) {
            final belowElement = sortedElements[currentIndex - 1];
            final tempZIndex = element.zIndex;
            element.zIndex = belowElement.zIndex;
            belowElement.zIndex = tempZIndex;
          }
          break;
        case ZIndexAction.sendToBack:
          final minZIndex = elements.map((e) => e.zIndex).reduce((a, b) => a < b ? a : b);
          element.zIndex = minZIndex - 1;
          break;
      }
    });
  }

  BaseCanvasElement _createTextElement(int x, int y) {
    return TextCanvasWidget(
      onRemove: () {},
      onPositionChanged: null,
      x: x,
      y: y,
    ).canvasElement;
  }

  BaseCanvasElement _createBoxElement(int x, int y) {
    return BoxCanvasWidget(
      onRemove: () {},
      onPositionChanged: null,
      x: x,
      y: y,
    ).canvasElement;
  }

  BaseCanvasElement _createBarcodeElement(int x, int y) {
    return BarcodeCanvasWidget(
      onRemove: () {},
      onPositionChanged: null,
      x: x,
      y: y,
    ).canvasElement;
  }

  BaseCanvasElement _createQRCodeElement(int x, int y) {
    return QRCodeCanvasWidget(
      onRemove: () {},
      onPositionChanged: null,
      x: x,
      y: y,
    ).canvasElement;
  }

  BaseCanvasElement _createLineElement(int x, int y) {
    return LineCanvasWidget(
      onRemove: () {},
      onPositionChanged: null,
      x: x,
      y: y,
    ).canvasElement;
  }

  Widget _buildElementWidget(BaseCanvasElement element, double pixelsPerMm) {
    void onRemove() {
      _removeElement(element);
    }

    void onPositionChanged(int newX, int newY) {
      setState(() {
        element.movePosition(newX, newY);
      });
    }

    void onSizeChanged(int newWidth, int newHeight) {
      setState(() {
        element.resize(newWidth, newHeight);
      });
    }

    void onZIndexChanged(ZIndexAction action) {
      _handleZIndexChange(element, action);
    }

    void onSelected() {
      context.read<EditorStateProvider>().selectElement(element);
    }

    if (element is TextCanvasElement) {
      return TextCanvasWidget(
        key: ValueKey(element.hashCode),
        canvasElement: element,
        onRemove: onRemove,
        onPositionChanged: onPositionChanged,
        onSizeChanged: onSizeChanged,
        onZIndexChanged: onZIndexChanged,
        onSelected: onSelected,
        pixelsPerMm: pixelsPerMm,
        x: element.x,
        y: element.y,
      );
    } else if (element is BoxCanvasElement) {
      return BoxCanvasWidget(
        key: ValueKey(element.hashCode),
        canvasElement: element,
        onRemove: onRemove,
        onPositionChanged: onPositionChanged,
        onSizeChanged: onSizeChanged,
        onZIndexChanged: onZIndexChanged,
        onSelected: onSelected,
        pixelsPerMm: pixelsPerMm,
        x: element.x,
        y: element.y,
      );
    } else if (element is BarcodeCanvasElement) {
      return BarcodeCanvasWidget(
        key: ValueKey(element.hashCode),
        canvasElement: element,
        onRemove: onRemove,
        onPositionChanged: onPositionChanged,
        onSizeChanged: onSizeChanged,
        onZIndexChanged: onZIndexChanged,
        onSelected: onSelected,
        pixelsPerMm: pixelsPerMm,
        x: element.x,
        y: element.y,
      );
    } else if (element is QRCodeCanvasElement) {
      return QRCodeCanvasWidget(
        key: ValueKey(element.hashCode),
        canvasElement: element,
        onRemove: onRemove,
        onPositionChanged: onPositionChanged,
        onSizeChanged: onSizeChanged,
        onZIndexChanged: onZIndexChanged,
        onSelected: onSelected,
        pixelsPerMm: pixelsPerMm,
        x: element.x,
        y: element.y,
      );
    } else if (element is LineCanvasElement) {
      return LineCanvasWidget(
        key: ValueKey(element.hashCode),
        canvasElement: element,
        onRemove: onRemove,
        onPositionChanged: onPositionChanged,
        onSizeChanged: onSizeChanged,
        onZIndexChanged: onZIndexChanged,
        onSelected: onSelected,
        pixelsPerMm: pixelsPerMm,
        x: element.x,
        y: element.y,
      );
    }

    return const SizedBox.shrink();
  }

  void _showExportDialog(BuildContext context) {
    final config = context.read<CanvasConfigProvider>();
    showDialog(
      context: context,
      builder: (context) => ZplExportDialog(
        elements: elements,
        widthMm: config.widthMm,
        heightMm: config.heightMm,
        dpmm: config.dpmm,
      ),
    );
  }

  Future<void> _showImportDialog(BuildContext context) async {
    final config = context.read<CanvasConfigProvider>();
    final result = await showDialog<List<BaseCanvasElement>>(
      context: context,
      builder: (context) => ZplImportDialog(dpmm: config.dpmm),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        if (elements.isNotEmpty) {
          elements.clear();
        }

        int nextZIndex = _getNextZIndex();
        for (final element in result) {
          final maxX = (config.widthMm - element.width).clamp(0, config.widthMm);
          final maxY = (config.heightMm - element.height).clamp(0, config.heightMm);
          element.x = element.x.clamp(0, maxX);
          element.y = element.y.clamp(0, maxY);
          element.zIndex = nextZIndex++;
          elements.add(element);
        }
      });
    }
  }

  void _showPreviewDialog(BuildContext context) {
    final config = context.read<CanvasConfigProvider>();
    showDialog(
      context: context,
      builder: (context) => ZplPreviewDialog(
        elements: elements,
        widthMm: config.widthMm,
        heightMm: config.heightMm,
        dpmm: config.dpmm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<CanvasConfigProvider>();
    final editorState = context.watch<EditorStateProvider>();

    // Adjust elements when canvas shrinks
    if (_lastCanvasWidth != null && _lastCanvasHeight != null) {
      if (config.widthMm < _lastCanvasWidth! || config.heightMm < _lastCanvasHeight!) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _adjustElementsToCanvas(config.widthMm, config.heightMm);
            });
          }
        });
      }
    }
    _lastCanvasWidth = config.widthMm;
    _lastCanvasHeight = config.heightMm;

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: AppTheme.bgPrimary,
        body: Column(
          children: [
            // Top Bar
            TopBar(
              onImport: () => _showImportDialog(context),
              onExport: elements.isEmpty ? null : () => _showExportDialog(context),
              onPreview: elements.isEmpty ? null : () => _showPreviewDialog(context),
              hasElements: elements.isNotEmpty,
            ),
            // Main content
            Expanded(
              child: Row(
                children: [
                  // Left: Tool Sidebar
                  ToolSidebar(
                    onToolDragStarted: (type) {
                      // Optional: visual feedback
                    },
                  ),
                  // Center: Canvas Area + Layers
                  Expanded(
                    child: Column(
                      children: [
                        // Canvas
                        Expanded(
                          flex: 3,
                          child: _buildCanvasArea(config, editorState),
                        ),
                        // Layers Panel
                        SizedBox(
                          height: 180,
                          child: LayersPanel(
                            elements: elements,
                            onSelect: (element) {
                              editorState.selectElement(element);
                            },
                            onDelete: (element) {
                              _removeElement(element);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right: Properties Panel
                  PropertiesPanel(
                    onPropertyChanged: () {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            // Status Bar
            StatusBar(elementCount: elements.length),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasArea(CanvasConfigProvider config, EditorStateProvider editorState) {
    return Container(
      color: AppTheme.canvasBg,
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final canvasAspectRatio = config.widthMm / config.heightMm;
            final maxWidth = constraints.maxWidth - AppTheme.spacingXl * 2;
            final maxHeight = constraints.maxHeight - AppTheme.spacingXl * 2;

            double canvasWidth = maxWidth;
            double canvasHeight = canvasWidth / canvasAspectRatio;

            if (canvasHeight > maxHeight) {
              canvasHeight = maxHeight;
              canvasWidth = canvasHeight * canvasAspectRatio;
            }

            // Apply zoom
            canvasWidth *= editorState.zoom;
            canvasHeight *= editorState.zoom;

            final pixelsPerMm = canvasWidth / config.widthMm;

            return GestureDetector(
              onTap: () {
                editorState.clearSelection();
              },
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingXl),
                    child: Container(
                      width: canvasWidth,
                      height: canvasHeight,
                      decoration: BoxDecoration(
                        color: AppTheme.canvasPaper,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        child: DragTarget<ToolType>(
                          onAcceptWithDetails: (details) {
                            final renderBox = context.findRenderObject() as RenderBox;
                            final localPos = renderBox.globalToLocal(details.offset);

                            final xMm = (localPos.dx / pixelsPerMm).round();
                            final yMm = (localPos.dy / pixelsPerMm).round();

                            _addElement(
                              details.data,
                              xMm.clamp(0, config.widthMm - 10),
                              yMm.clamp(0, config.heightMm - 10),
                            );
                          },
                          builder: (_, __, ___) => Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Grid layer
                              if (config.showGrid)
                                Positioned.fill(
                                  child: CanvasGrid(
                                    width: canvasWidth,
                                    height: canvasHeight,
                                    widthMm: config.widthMm,
                                    heightMm: config.heightMm,
                                  ),
                                ),
                              // Elements layer
                              ...(List<BaseCanvasElement>.from(elements)
                                    ..sort((a, b) => a.zIndex.compareTo(b.zIndex)))
                                  .map((element) {
                                final pixelX = element.x * pixelsPerMm;
                                final pixelY = element.y * pixelsPerMm;
                                final pixelWidth = element.width * pixelsPerMm;
                                final pixelHeight = element.height * pixelsPerMm;

                                return Positioned(
                                  left: pixelX,
                                  top: pixelY,
                                  width: pixelWidth,
                                  height: pixelHeight,
                                  child: _buildElementWidget(element, pixelsPerMm),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
