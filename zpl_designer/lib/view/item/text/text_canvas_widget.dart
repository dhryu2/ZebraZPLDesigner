import 'package:flutter/material.dart';
import 'package:zpl_designer/core/base_canvas_element.dart';
import 'package:zpl_designer/core/base_canvas_item.dart';
import 'package:zpl_designer/view/item/text/text_canvas_element.dart';

class TextCanvasWidget extends BaseCanvasItem<TextCanvasElement> {
  TextCanvasWidget({
    super.key,
    required super.onRemove,
    required super.onPositionChanged,
    super.onSizeChanged,
    super.onZIndexChanged,
    super.onSelected,
    super.pixelsPerMm,
    TextCanvasElement? canvasElement,
    required int x,
    required int y,
    int width = 25,
    int height = 8,
  }) : super(
         canvasElement: canvasElement ?? TextCanvasElement(
           x: x,
           y: y,
           width: width,
           height: height,
         ),
       );

  @override
  State<StatefulWidget> createState() => _TextCanvasWidgetState();
}

class _TextCanvasWidgetState
    extends BaseCanvasItemState<TextCanvasWidget, TextCanvasElement> {
  Alignment _getTextAlignment() {
    switch (element.alignment) {
      case TextAlignment.left:
        return Alignment.centerLeft;
      case TextAlignment.center:
        return Alignment.center;
      case TextAlignment.right:
        return Alignment.centerRight;
      case TextAlignment.justified:
        return Alignment.centerLeft;
    }
  }

  /// ZplRotation을 RotatedBox의 quarterTurns로 변환
  int _getQuarterTurns() {
    return switch (element.rotation) {
      ZplRotation.normal => 0,
      ZplRotation.rotated90 => 1,
      ZplRotation.inverted => 2,
      ZplRotation.rotated270 => 3,
    };
  }

  @override
  Widget renderElement(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 회전 시 폰트 크기 계산을 위한 실제 높이 결정
        final isRotated90or270 = element.rotation == ZplRotation.rotated90 ||
                                  element.rotation == ZplRotation.rotated270;
        final effectiveHeight = isRotated90or270 ? constraints.maxWidth : constraints.maxHeight;
        final fontSize = (effectiveHeight * 0.6).clamp(8.0, 100.0);

        Widget textContent = Container(
          decoration: element.showBorder
              ? BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: element.borderThickness.toDouble().clamp(1, 5),
                  ),
                )
              : null,
          padding: const EdgeInsets.all(2),
          child: Align(
            alignment: _getTextAlignment(),
            child: Text(
              element.text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: element.maxLine ?? 1,
              textAlign: element.alignment == TextAlignment.center
                  ? TextAlign.center
                  : element.alignment == TextAlignment.right
                      ? TextAlign.right
                      : TextAlign.left,
            ),
          ),
        );

        // 회전 적용 - RotatedBox로 레이아웃 회전
        if (element.rotation != ZplRotation.normal) {
          textContent = RotatedBox(
            quarterTurns: _getQuarterTurns(),
            child: textContent,
          );
        }

        return textContent;
      },
    );
  }

  @override
  List<PropertyItem> addEditPropertyItems() {
    final textController = TextEditingController(text: element.text);
    final fontHeightController = TextEditingController(
      text: element.fontHeight.toString(),
    );
    final fontWidthController = TextEditingController(
      text: element.fontWidth.toString(),
    );
    final maxLineController = TextEditingController(
      text: element.maxLine?.toString() ?? '',
    );
    final borderThicknessController = TextEditingController(
      text: element.borderThickness.toString(),
    );
    ZplFont selectedFont = element.font;
    ZplRotation selectedRotation = element.rotation;
    TextAlignment selectedAlignment = element.alignment;
    bool showBorder = element.showBorder;

    return [
      PropertyItem(
        propertyWidget: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Text',
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            helperText: "표시할 텍스트",
          ),
          maxLines: 3,
        ),
        saveProperty: () {
          element.text = textController.text;
        },
      ),
      PropertyItem(
        propertyWidget: StatefulBuilder(
          builder: (context, setLocalState) {
            return DropdownButtonFormField<ZplFont>(
              initialValue: selectedFont,
              decoration: const InputDecoration(
                labelText: 'Font',
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
              items: ZplFont.values.map((font) {
                return DropdownMenuItem(
                  value: font,
                  child: Text(font.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setLocalState(() {
                    selectedFont = value;
                  });
                }
              },
            );
          },
        ),
        saveProperty: () {
          element.font = selectedFont;
        },
      ),
      PropertyItem(
        propertyWidget: StatefulBuilder(
          builder: (context, setLocalState) {
            return Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ZplRotation>(
                    value: selectedRotation,
                    decoration: const InputDecoration(
                      labelText: 'Rotation',
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                    items: ZplRotation.values.map((r) {
                      return DropdownMenuItem(
                        value: r,
                        child: Text(r.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setLocalState(() {
                          selectedRotation = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<TextAlignment>(
                    value: selectedAlignment,
                    decoration: const InputDecoration(
                      labelText: 'Alignment',
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                    items: TextAlignment.values.map((a) {
                      return DropdownMenuItem(
                        value: a,
                        child: Text(a.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setLocalState(() {
                          selectedAlignment = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
        saveProperty: () {
          element.rotation = selectedRotation;
          element.alignment = selectedAlignment;
        },
      ),
      PropertyItem(
        propertyWidget: Row(
          children: [
            Expanded(
              child: TextField(
                controller: fontHeightController,
                decoration: const InputDecoration(
                  labelText: 'Font Height',
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: fontWidthController,
                decoration: const InputDecoration(
                  labelText: 'Font Width',
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        saveProperty: () {
          element.fontHeight = (int.tryParse(fontHeightController.text) ?? 30).clamp(10, 500);
          element.fontWidth = (int.tryParse(fontWidthController.text) ?? 30).clamp(10, 500);
        },
      ),
      PropertyItem(
        propertyWidget: TextField(
          controller: maxLineController,
          decoration: const InputDecoration(
            labelText: 'Max Lines',
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            helperText: "최대 줄 수 (비워두면 제한 없음)",
          ),
          keyboardType: TextInputType.number,
        ),
        saveProperty: () {
          final value = int.tryParse(maxLineController.text);
          element.maxLine = value != null && value > 0 ? value : null;
        },
      ),
      PropertyItem(
        propertyWidget: StatefulBuilder(
          builder: (context, setLocalState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: showBorder,
                      onChanged: (value) {
                        setLocalState(() {
                          showBorder = value ?? false;
                        });
                      },
                    ),
                    const Text('테두리 표시'),
                  ],
                ),
                if (showBorder)
                  TextField(
                    controller: borderThicknessController,
                    decoration: const InputDecoration(
                      labelText: 'Border Thickness',
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      helperText: "테두리 두께 (1-10)",
                    ),
                    keyboardType: TextInputType.number,
                  ),
              ],
            );
          },
        ),
        saveProperty: () {
          element.showBorder = showBorder;
          element.borderThickness = (int.tryParse(borderThicknessController.text) ?? 2).clamp(1, 10);
        },
      ),
    ];
  }
}
