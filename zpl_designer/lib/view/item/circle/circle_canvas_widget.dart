import 'package:flutter/material.dart';
import 'package:zpl_designer/core/base_canvas_item.dart';
import 'package:zpl_designer/view/item/circle/circle_canvas_element.dart';

class CircleCanvasWidget extends BaseCanvasItem<CircleCanvasElement> {
  CircleCanvasWidget({
    super.key,
    required super.onRemove,
    required super.onPositionChanged,
    super.onSizeChanged,
    super.onZIndexChanged,
    super.onSelected,
    super.pixelsPerMm,
    CircleCanvasElement? canvasElement,
    required int x,
    required int y,
    int width = 20,
    int height = 20,
  }) : super(
         canvasElement: canvasElement ?? CircleCanvasElement(
           x: x,
           y: y,
           width: width,
           height: height,
         ),
       );

  @override
  State<StatefulWidget> createState() => _CircleCanvasWidgetState();
}

class _CircleCanvasWidgetState
    extends BaseCanvasItemState<CircleCanvasWidget, CircleCanvasElement> {
  @override
  Widget renderElement(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        return Center(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black,
                width: element.thickness.toDouble().clamp(1, 10),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  List<PropertyItem> addEditPropertyItems() {
    final thicknessController = TextEditingController(
      text: element.thickness.toString(),
    );
    final diameterController = TextEditingController(
      text: element.diameter.toString(),
    );

    return [
      PropertyItem(
        propertyWidget: TextField(
          controller: diameterController,
          decoration: const InputDecoration(
            labelText: 'Diameter',
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            helperText: "원 지름 (mm)",
          ),
          keyboardType: TextInputType.number,
        ),
        saveProperty: () {
          element.diameter = (int.tryParse(diameterController.text) ?? 20).clamp(5, 500);
          // 원은 width와 height가 같아야 함
          element.width = element.diameter;
          element.height = element.diameter;
        },
      ),
      PropertyItem(
        propertyWidget: TextField(
          controller: thicknessController,
          decoration: const InputDecoration(
            labelText: 'Thickness',
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            helperText: "선 두께 (1-20)",
          ),
          keyboardType: TextInputType.number,
        ),
        saveProperty: () {
          element.thickness = (int.tryParse(thicknessController.text) ?? 2).clamp(1, 20);
        },
      ),
    ];
  }
}
