import 'package:flutter/material.dart';
import 'package:zpl_designer/core/base_canvas_item.dart';
import 'package:zpl_designer/view/item/ellipse/ellipse_canvas_element.dart';

class EllipseCanvasWidget extends BaseCanvasItem<EllipseCanvasElement> {
  EllipseCanvasWidget({
    super.key,
    required super.onRemove,
    required super.onPositionChanged,
    super.onSizeChanged,
    super.onZIndexChanged,
    super.onSelected,
    super.pixelsPerMm,
    EllipseCanvasElement? canvasElement,
    required int x,
    required int y,
    int width = 30,
    int height = 20,
  }) : super(
         canvasElement: canvasElement ?? EllipseCanvasElement(
           x: x,
           y: y,
           width: width,
           height: height,
         ),
       );

  @override
  State<StatefulWidget> createState() => _EllipseCanvasWidgetState();
}

class _EllipseCanvasWidgetState
    extends BaseCanvasItemState<EllipseCanvasWidget, EllipseCanvasElement> {
  @override
  Widget renderElement(BuildContext context) {
    return CustomPaint(
      painter: _EllipsePainter(thickness: element.thickness.toDouble()),
      size: Size.infinite,
    );
  }

  @override
  List<PropertyItem> addEditPropertyItems() {
    final thicknessController = TextEditingController(
      text: element.thickness.toString(),
    );

    return [
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

class _EllipsePainter extends CustomPainter {
  final double thickness;

  _EllipsePainter({required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(
      thickness / 2,
      thickness / 2,
      size.width - thickness,
      size.height - thickness,
    );
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _EllipsePainter oldDelegate) {
    return oldDelegate.thickness != thickness;
  }
}
