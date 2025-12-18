import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zpl_designer/provider/canvas_config_provider.dart';
import 'package:zpl_designer/view/tools/tool_icon.dart';
import 'package:zpl_designer/view/tools/tool_type.dart';
import 'package:zpl_designer/view/widget/dpmm_dropdown.dart';

enum SizeUnit {
  mm('mm'),
  inch('inch');

  final String label;
  const SizeUnit(this.label);

  // inch to mm
  double toMm(double value) {
    return this == SizeUnit.inch ? value * 25.4 : value;
  }

  // mm to this unit
  double fromMm(double mm) {
    return this == SizeUnit.inch ? mm / 25.4 : mm;
  }
}

class ToolPalette extends StatefulWidget {
  const ToolPalette({super.key});

  @override
  State<ToolPalette> createState() => _ToolPaletteState();
}

class _ToolPaletteState extends State<ToolPalette> {
  late TextEditingController widthController;
  late TextEditingController heightController;
  SizeUnit _unit = SizeUnit.mm;

  @override
  void initState() {
    super.initState();
    final config = context.read<CanvasConfigProvider>();
    widthController = TextEditingController(text: config.widthMm.toString());
    heightController = TextEditingController(text: config.heightMm.toString());
  }

  @override
  void dispose() {
    widthController.dispose();
    heightController.dispose();
    super.dispose();
  }

  void _updateDisplayValues() {
    final config = context.read<CanvasConfigProvider>();
    final widthInUnit = _unit.fromMm(config.widthMm.toDouble());
    final heightInUnit = _unit.fromMm(config.heightMm.toDouble());

    // inch인 경우 소수점 2자리까지, mm인 경우 정수
    if (_unit == SizeUnit.inch) {
      widthController.text = widthInUnit.toStringAsFixed(2);
      heightController.text = heightInUnit.toStringAsFixed(2);
    } else {
      widthController.text = widthInUnit.round().toString();
      heightController.text = heightInUnit.round().toString();
    }
  }

  void _onUnitChanged(SizeUnit? newUnit) {
    if (newUnit != null && newUnit != _unit) {
      setState(() {
        _unit = newUnit;
        _updateDisplayValues();
      });
    }
  }

  void _onWidthChanged(String value) {
    final width = double.tryParse(value);
    if (width != null && width > 0) {
      final widthMm = _unit.toMm(width).round();
      context.read<CanvasConfigProvider>().widthMm = widthMm;
    }
  }

  void _onHeightChanged(String value) {
    final height = double.tryParse(value);
    if (height != null && height > 0) {
      final heightMm = _unit.toMm(height).round();
      context.read<CanvasConfigProvider>().heightMm = heightMm;
    }
  }

  @override
  Widget build(BuildContext ctx) {
    final tools = [ToolType.text, ToolType.box, ToolType.barcode, ToolType.qr, ToolType.line];
    final config = context.watch<CanvasConfigProvider>();

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          ...tools.map(
            (tool) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Draggable<ToolType>(
                data: tool,
                feedback: Opacity(opacity: 0.7, child: ToolIcon(tool)),
                child: ToolIcon(tool),
              ),
            ),
          ),
          const SizedBox(width: 10),
          DpmmDropdown(
            initialValue: config.dpmm,
            onChanged: (value) {
              context.read<CanvasConfigProvider>().dpmm = value;
            },
          ),
          const SizedBox(width: 20),
          // 단위 선택 드롭다운
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<SizeUnit>(
                value: _unit,
                isDense: true,
                items: SizeUnit.values.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit.label),
                  );
                }).toList(),
                onChanged: _onUnitChanged,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text("Width:"),
          const SizedBox(width: 4),
          SizedBox(
            width: 70,
            child: TextField(
              controller: widthController,
              onChanged: _onWidthChanged,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(isDense: true),
            ),
          ),
          const SizedBox(width: 12),
          Text("Height:"),
          const SizedBox(width: 4),
          SizedBox(
            width: 70,
            child: TextField(
              controller: heightController,
              onChanged: _onHeightChanged,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(isDense: true),
            ),
          ),
          const SizedBox(width: 20),
          IconButton(
            icon: Icon(
              config.showGrid ? Icons.grid_on : Icons.grid_off,
              color: config.showGrid ? Colors.blue : Colors.grey,
            ),
            tooltip: config.showGrid ? '그리드 숨기기' : '그리드 표시',
            onPressed: () {
              context.read<CanvasConfigProvider>().toggleGrid();
            },
          ),
        ],
      ),
    );
  }
}
