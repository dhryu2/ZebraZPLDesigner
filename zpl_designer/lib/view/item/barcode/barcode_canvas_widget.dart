import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:zpl_designer/core/base_canvas_element.dart';
import 'package:zpl_designer/core/base_canvas_item.dart';
import 'package:zpl_designer/view/item/barcode/barcode_canvas_element.dart';

class BarcodeCanvasWidget extends BaseCanvasItem<BarcodeCanvasElement> {
  BarcodeCanvasWidget({
    super.key,
    required super.onRemove,
    required super.onPositionChanged,
    super.onSizeChanged,
    super.onZIndexChanged,
    super.onSelected,
    super.pixelsPerMm,
    BarcodeCanvasElement? canvasElement,
    required int x,
    required int y,
    int width = 30,
    int height = 15,
  }) : super(
         canvasElement: canvasElement ?? BarcodeCanvasElement(
           x: x,
           y: y,
           width: width,
           height: height,
         ),
       );

  @override
  State<StatefulWidget> createState() => _BarcodeCanvasWidgetState();
}

class _BarcodeCanvasWidgetState
    extends BaseCanvasItemState<BarcodeCanvasWidget, BarcodeCanvasElement> {
  @override
  Widget renderElement(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textHeight = element.showText ? 12.0 : 0.0;
        Widget content = Container(
          decoration: element.showBorder
              ? BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: element.borderThickness.toDouble().clamp(1, 5),
                  ),
                )
              : null,
          padding: const EdgeInsets.all(2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: CustomPaint(
                  painter: _BarcodePainter(element.data),
                  size: Size(constraints.maxWidth - 4, constraints.maxHeight - textHeight - 4),
                ),
              ),
              if (element.showText)
                Text(
                  element.data,
                  style: TextStyle(
                    fontSize: (constraints.maxHeight * 0.15).clamp(6.0, 12.0),
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
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
    final moduleWidthController = TextEditingController(
      text: element.moduleWidth.toString(),
    );
    final barcodeHeightController = TextEditingController(
      text: element.barcodeHeight.toString(),
    );
    final borderThicknessController = TextEditingController(
      text: element.borderThickness.toString(),
    );
    BarcodeType selectedType = element.barcodeType;
    ZplRotation selectedRotation = element.rotation;
    bool showText = element.showText;
    bool showBorder = element.showBorder;

    return [
      PropertyItem(
        propertyWidget: StatefulBuilder(
          builder: (context, setLocalState) {
            return DropdownButtonFormField<BarcodeType>(
              initialValue: selectedType,
              decoration: const InputDecoration(
                labelText: 'Barcode Type',
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
              items: BarcodeType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setLocalState(() {
                    selectedType = value;
                  });
                }
              },
            );
          },
        ),
        saveProperty: () {
          element.barcodeType = selectedType;
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
      PropertyItem(
        propertyWidget: TextField(
          controller: dataController,
          decoration: const InputDecoration(
            labelText: 'Data',
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            helperText: "바코드 데이터",
          ),
        ),
        saveProperty: () {
          element.data = dataController.text;
        },
      ),
      PropertyItem(
        propertyWidget: TextField(
          controller: moduleWidthController,
          decoration: const InputDecoration(
            labelText: 'Module Width',
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            helperText: "바 너비 (1-10)",
          ),
          keyboardType: TextInputType.number,
        ),
        saveProperty: () {
          element.moduleWidth = (int.tryParse(moduleWidthController.text) ?? 2).clamp(1, 10);
        },
      ),
      PropertyItem(
        propertyWidget: TextField(
          controller: barcodeHeightController,
          decoration: const InputDecoration(
            labelText: 'Barcode Height',
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            helperText: "바코드 높이",
          ),
          keyboardType: TextInputType.number,
        ),
        saveProperty: () {
          element.barcodeHeight = (int.tryParse(barcodeHeightController.text) ?? 50).clamp(10, 500);
        },
      ),
      PropertyItem(
        propertyWidget: StatefulBuilder(
          builder: (context, setLocalState) {
            return CheckboxListTile(
              title: const Text('Show Text'),
              value: showText,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setLocalState(() {
                  showText = value ?? true;
                });
              },
            );
          },
        ),
        saveProperty: () {
          element.showText = showText;
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

class _BarcodePainter extends CustomPainter {
  final String data;

  _BarcodePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // 간단한 바코드 시각화 (실제 바코드 인코딩이 아닌 시각적 표현)
    final barWidth = size.width / (data.length * 4 + 10);
    double x = barWidth * 2;

    // Start bars
    canvas.drawRect(Rect.fromLTWH(x, 0, barWidth, size.height), paint);
    x += barWidth * 2;
    canvas.drawRect(Rect.fromLTWH(x, 0, barWidth, size.height), paint);
    x += barWidth * 2;

    // Data bars (simplified visualization)
    for (int i = 0; i < data.length; i++) {
      final charCode = data.codeUnitAt(i);
      for (int j = 0; j < 3; j++) {
        if ((charCode + j) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(x, 0, barWidth * (1 + (charCode % 2)), size.height),
            paint,
          );
        }
        x += barWidth * 2;
      }
    }

    // End bars
    canvas.drawRect(Rect.fromLTWH(x, 0, barWidth, size.height), paint);
    x += barWidth * 2;
    canvas.drawRect(Rect.fromLTWH(x, 0, barWidth, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
