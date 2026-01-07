import 'package:flutter/material.dart';
import 'package:zpl_designer/core/base_canvas_item.dart';
import 'package:zpl_designer/view/item/diagonal/diagonal_canvas_element.dart';

class DiagonalCanvasWidget extends BaseCanvasItem<DiagonalCanvasElement> {
  DiagonalCanvasWidget({
    super.key,
    required super.onRemove,
    required super.onPositionChanged,
    super.onSizeChanged,
    super.onZIndexChanged,
    super.onSelected,
    super.pixelsPerMm,
    DiagonalCanvasElement? canvasElement,
    required int x,
    required int y,
    int width = 20,
    int height = 20,
  }) : super(
         canvasElement: canvasElement ?? DiagonalCanvasElement(
           x: x,
           y: y,
           width: width,
           height: height,
         ),
       );

  @override
  State<StatefulWidget> createState() => _DiagonalCanvasWidgetState();
}

class _DiagonalCanvasWidgetState
    extends BaseCanvasItemState<DiagonalCanvasWidget, DiagonalCanvasElement> {
  @override
  Widget renderElement(BuildContext context) {
    return CustomPaint(
      painter: _DiagonalPainter(
        thickness: element.thickness.toDouble(),
        orientation: element.orientation,
      ),
      size: Size.infinite,
    );
  }

  @override
  List<PropertyItem> addEditPropertyItems() {
    final thicknessController = TextEditingController(
      text: element.thickness.toString(),
    );
    DiagonalOrientation selectedOrientation = element.orientation;

    return [
      PropertyItem(
        propertyWidget: StatefulBuilder(
          builder: (context, setLocalState) {
            return DropdownButtonFormField<DiagonalOrientation>(
              value: selectedOrientation,
              decoration: const InputDecoration(
                labelText: 'Orientation',
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
              items: DiagonalOrientation.values.map((o) {
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

class _DiagonalPainter extends CustomPainter {
  final double thickness;
  final DiagonalOrientation orientation;

  _DiagonalPainter({
    required this.thickness,
    required this.orientation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    if (orientation == DiagonalOrientation.rightLeaning) {
      // Right-leaning diagonal (/)
      canvas.drawLine(
        Offset(0, size.height),
        Offset(size.width, 0),
        paint,
      );
    } else {
      // Left-leaning diagonal (\)
      canvas.drawLine(
        Offset(0, 0),
        Offset(size.width, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DiagonalPainter oldDelegate) {
    return oldDelegate.thickness != thickness ||
           oldDelegate.orientation != orientation;
  }
}
