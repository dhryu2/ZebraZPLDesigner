import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:zpl_designer/core/base_canvas_element.dart';
import 'package:zpl_designer/core/base_canvas_item.dart';
import 'package:zpl_designer/view/item/qrcode/qrcode_canvas_element.dart';

class QRCodeCanvasWidget extends BaseCanvasItem<QRCodeCanvasElement> {
  QRCodeCanvasWidget({
    super.key,
    required super.onRemove,
    required super.onPositionChanged,
    super.onSizeChanged,
    super.onZIndexChanged,
    super.onSelected,
    super.pixelsPerMm,
    QRCodeCanvasElement? canvasElement,
    required int x,
    required int y,
    int width = 15,
    int height = 15,
  }) : super(
         canvasElement: canvasElement ?? QRCodeCanvasElement(
           x: x,
           y: y,
           width: width,
           height: height,
         ),
       );

  @override
  State<StatefulWidget> createState() => _QRCodeCanvasWidgetState();
}

class _QRCodeCanvasWidgetState
    extends BaseCanvasItemState<QRCodeCanvasWidget, QRCodeCanvasElement> {
  @override
  Widget renderElement(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        Widget content = Container(
          decoration: element.showBorder
              ? BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: element.borderThickness.toDouble().clamp(1, 5),
                  ),
                )
              : null,
          child: Center(
            child: CustomPaint(
              painter: _QRCodePainter(element.data),
              size: Size(size - 4, size - 4),
            ),
          ),
        );

        // 회전 적용
        if (element.rotation != ZplRotation.normal) {
          content = Transform.rotate(
            angle: element.rotation.degrees * math.pi / 180,
            child: content,
          );
        }

        return content;
      },
    );
  }

  @override
  List<PropertyItem> addEditPropertyItems() {
    final dataController = TextEditingController(text: element.data);
    final magnificationController = TextEditingController(
      text: element.magnification.toString(),
    );
    final borderThicknessController = TextEditingController(
      text: element.borderThickness.toString(),
    );
    QRErrorCorrection selectedErrorCorrection = element.errorCorrection;
    ZplRotation selectedRotation = element.rotation;
    bool showBorder = element.showBorder;

    return [
      PropertyItem(
        propertyWidget: TextField(
          controller: dataController,
          decoration: const InputDecoration(
            labelText: 'Data',
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            helperText: "QR 코드에 저장할 데이터",
          ),
          maxLines: 3,
        ),
        saveProperty: () {
          element.data = dataController.text;
        },
      ),
      PropertyItem(
        propertyWidget: TextField(
          controller: magnificationController,
          decoration: const InputDecoration(
            labelText: 'Magnification',
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            helperText: "크기 배율 (1-10)",
          ),
          keyboardType: TextInputType.number,
        ),
        saveProperty: () {
          element.magnification = (int.tryParse(magnificationController.text) ?? 4).clamp(1, 10);
        },
      ),
      PropertyItem(
        propertyWidget: StatefulBuilder(
          builder: (context, setLocalState) {
            return Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<QRErrorCorrection>(
                    value: selectedErrorCorrection,
                    decoration: const InputDecoration(
                      labelText: 'Error Correction',
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                    items: QRErrorCorrection.values.map((ec) {
                      return DropdownMenuItem(
                        value: ec,
                        child: Text(ec.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setLocalState(() {
                          selectedErrorCorrection = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
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
              ],
            );
          },
        ),
        saveProperty: () {
          element.errorCorrection = selectedErrorCorrection;
          element.rotation = selectedRotation;
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

class _QRCodePainter extends CustomPainter {
  final String data;

  _QRCodePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final cellSize = size.width / 25;

    // 간단한 QR 코드 시각화 (실제 QR 인코딩이 아닌 패턴 표현)
    // Position detection patterns (3개의 모서리)
    _drawFinderPattern(canvas, paint, 0, 0, cellSize);
    _drawFinderPattern(canvas, paint, size.width - cellSize * 7, 0, cellSize);
    _drawFinderPattern(canvas, paint, 0, size.height - cellSize * 7, cellSize);

    // Timing patterns
    for (int i = 8; i < 17; i++) {
      if (i % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(i * cellSize, 6 * cellSize, cellSize, cellSize),
          paint,
        );
        canvas.drawRect(
          Rect.fromLTWH(6 * cellSize, i * cellSize, cellSize, cellSize),
          paint,
        );
      }
    }

    // 데이터 기반 pseudo-random 패턴
    final hash = data.hashCode.abs();
    for (int row = 9; row < 23; row++) {
      for (int col = 9; col < 23; col++) {
        if ((hash + row * col) % 3 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize),
            paint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, Paint paint, double x, double y, double cellSize) {
    // Outer black square
    canvas.drawRect(
      Rect.fromLTWH(x, y, cellSize * 7, cellSize * 7),
      paint,
    );

    // Inner white square
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(x + cellSize, y + cellSize, cellSize * 5, cellSize * 5),
      whitePaint,
    );

    // Center black square
    canvas.drawRect(
      Rect.fromLTWH(x + cellSize * 2, y + cellSize * 2, cellSize * 3, cellSize * 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
