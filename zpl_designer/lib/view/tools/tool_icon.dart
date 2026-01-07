import 'package:flutter/material.dart';
import 'package:zpl_designer/view/tools/tool_type.dart';

class ToolIcon extends StatelessWidget {
  final ToolType type;

  const ToolIcon(this.type, {super.key});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String label;

    switch (type) {
      case ToolType.text:
        icon = Icons.text_fields;
        label = "Text";
        break;
      case ToolType.barcode:
        icon = Icons.qr_code_2;
        label = "Barcode";
        break;
      case ToolType.qr:
        icon = Icons.qr_code;
        label = "QR Code";
        break;
      case ToolType.box:
        icon = Icons.crop_square;
        label = "Box";
        break;
      case ToolType.line:
        icon = Icons.horizontal_rule;
        label = "Line";
        break;
      case ToolType.diagonal:
        icon = Icons.show_chart;
        label = "Diagonal";
        break;
      case ToolType.circle:
        icon = Icons.circle_outlined;
        label = "Circle";
        break;
      case ToolType.ellipse:
        icon = Icons.panorama_fish_eye;
        label = "Ellipse";
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon), Text(label, style: TextStyle(fontSize: 12))],
    );
  }
}
