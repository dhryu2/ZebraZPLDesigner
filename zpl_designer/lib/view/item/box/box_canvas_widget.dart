import 'package:flutter/material.dart';
import 'package:zpl_designer/core/base_canvas_element.dart';
import 'package:zpl_designer/core/base_canvas_item.dart';
import 'package:zpl_designer/view/item/box/box_canvas_element.dart';

class BoxCanvasWidget extends BaseCanvasItem<BoxCanvasElement> {
  BoxCanvasWidget({
    super.key,
    required super.onRemove,
    required super.onPositionChanged,
    super.onSizeChanged,
    super.onZIndexChanged,
    super.onSelected,
    super.pixelsPerMm,
    BoxCanvasElement? canvasElement,
    required int x,
    required int y,
    int width = 20,
    int height = 15,
    int thickness = 1,
  }) : super(
         canvasElement: canvasElement ?? BoxCanvasElement(
           x: x,
           y: y,
           width: width,
           height: height,
           thickness: thickness,
         ),
       );

  @override
  State<StatefulWidget> createState() => _BoxCanvasWidgetState();
}

class _BoxCanvasWidgetState
    extends BaseCanvasItemState<BoxCanvasWidget, BoxCanvasElement> {
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
    Widget content = Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: element.thickness.toDouble().clamp(1, 10),
        ),
        color: Colors.transparent,
      ),
    );

    // 회전 적용 - RotatedBox로 레이아웃 회전 (시각적 효과만, ZPL ^GB는 회전 미지원)
    if (element.rotation != ZplRotation.normal) {
      content = RotatedBox(
        quarterTurns: _getQuarterTurns(),
        child: content,
      );
    }

    return content;
  }

  @override
  List<PropertyItem> addEditPropertyItems() {
    final thicknessController = TextEditingController(
      text: element.thickness.toString(),
    );
    ZplRotation selectedRotation = element.rotation;

    return [
      PropertyItem(
        propertyWidget: TextField(
          controller: thicknessController,
          decoration: const InputDecoration(
            labelText: 'Border Thickness',
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            helperText: "테두리 두께 (1-10)",
          ),
          keyboardType: TextInputType.number,
        ),
        saveProperty: () {
          element.thickness = (int.tryParse(thicknessController.text) ?? 2).clamp(1, 100);
        },
      ),
      PropertyItem(
        propertyWidget: StatefulBuilder(
          builder: (context, setLocalState) {
            return DropdownButtonFormField<ZplRotation>(
              value: selectedRotation,
              decoration: const InputDecoration(
                labelText: 'Rotation',
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                helperText: "시각적 회전 (ZPL에서 미지원)",
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
            );
          },
        ),
        saveProperty: () {
          element.rotation = selectedRotation;
        },
      ),
    ];
  }
}
