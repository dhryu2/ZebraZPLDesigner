import 'package:flutter/material.dart';
import 'package:zpl_designer/core/base_canvas_item.dart';
import 'package:zpl_designer/view/item/line/line_canvas_element.dart';

class LineCanvasWidget extends BaseCanvasItem<LineCanvasElement> {
  LineCanvasWidget({
    super.key,
    required super.onRemove,
    required super.onPositionChanged,
    super.onSizeChanged,
    super.onZIndexChanged,
    super.onSelected,
    super.pixelsPerMm,
    LineCanvasElement? canvasElement,
    required int x,
    required int y,
    int width = 30,
    int height = 2,
  }) : super(
         canvasElement: canvasElement ?? LineCanvasElement(
           x: x,
           y: y,
           width: width,
           height: height,
         ),
       );

  @override
  State<StatefulWidget> createState() => _LineCanvasWidgetState();
}

class _LineCanvasWidgetState
    extends BaseCanvasItemState<LineCanvasWidget, LineCanvasElement> {
  @override
  Widget renderElement(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (element.orientation == LineOrientation.horizontal) {
          return Center(
            child: Container(
              width: constraints.maxWidth,
              height: element.thickness.toDouble().clamp(1, 20),
              color: Colors.black,
            ),
          );
        } else {
          return Center(
            child: Container(
              width: element.thickness.toDouble().clamp(1, 20),
              height: constraints.maxHeight,
              color: Colors.black,
            ),
          );
        }
      },
    );
  }

  @override
  List<PropertyItem> addEditPropertyItems() {
    final thicknessController = TextEditingController(
      text: element.thickness.toString(),
    );
    LineOrientation selectedOrientation = element.orientation;

    return [
      PropertyItem(
        propertyWidget: StatefulBuilder(
          builder: (context, setLocalState) {
            return DropdownButtonFormField<LineOrientation>(
              value: selectedOrientation,
              decoration: const InputDecoration(
                labelText: 'Orientation',
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
              items: LineOrientation.values.map((o) {
                return DropdownMenuItem(
                  value: o,
                  child: Text(o.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setLocalState(() {
                    selectedOrientation = value;
                  });
                }
              },
            );
          },
        ),
        saveProperty: () {
          element.orientation = selectedOrientation;
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
