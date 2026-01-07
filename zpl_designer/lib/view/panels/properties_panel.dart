import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zpl_designer/core/app_theme.dart';
import 'package:zpl_designer/core/base_canvas_element.dart';
import 'package:zpl_designer/core/dpmm.dart';
import 'package:zpl_designer/provider/canvas_config_provider.dart';
import 'package:zpl_designer/provider/editor_state_provider.dart';
import 'package:zpl_designer/view/item/barcode/barcode_canvas_element.dart';
import 'package:zpl_designer/view/item/box/box_canvas_element.dart';
import 'package:zpl_designer/view/item/circle/circle_canvas_element.dart';
import 'package:zpl_designer/view/item/diagonal/diagonal_canvas_element.dart';
import 'package:zpl_designer/view/item/ellipse/ellipse_canvas_element.dart';
import 'package:zpl_designer/view/item/line/line_canvas_element.dart';
import 'package:zpl_designer/view/item/qrcode/qrcode_canvas_element.dart';
import 'package:zpl_designer/view/item/text/text_canvas_element.dart';

class PropertiesPanel extends StatelessWidget {
  final VoidCallback? onPropertyChanged;

  const PropertiesPanel({super.key, this.onPropertyChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppTheme.rightPanelWidth,
      alignment: Alignment.topCenter,
      decoration: const BoxDecoration(
        color: AppTheme.bgSecondary,
        border: Border(
          left: BorderSide(color: AppTheme.surfaceBorder),
        ),
      ),
      child: Consumer<EditorStateProvider>(
        builder: (context, state, child) {
          final element = state.selectedElement;

          if (element == null) {
            return _CanvasSettings(onChanged: onPropertyChanged);
          }

          return _PropertyEditor(
            key: ValueKey(element.hashCode),
            element: element,
            onChanged: onPropertyChanged,
          );
        },
      ),
    );
  }
}

enum SizeUnit {
  mm('mm', 1.0),
  inch('inch', 25.4);

  final String displayName;
  final double toMmFactor;

  const SizeUnit(this.displayName, this.toMmFactor);
}

class _CanvasSettings extends StatefulWidget {
  final VoidCallback? onChanged;

  const _CanvasSettings({this.onChanged});

  @override
  State<_CanvasSettings> createState() => _CanvasSettingsState();
}

class _CanvasSettingsState extends State<_CanvasSettings> {
  SizeUnit _unit = SizeUnit.mm;
  late TextEditingController _widthController;
  late TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _widthController = TextEditingController();
    _heightController = TextEditingController();
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _updateControllers(CanvasConfigProvider config) {
    final width = _unit == SizeUnit.mm
        ? config.widthMm.toDouble()
        : config.widthMm / 25.4;
    final height = _unit == SizeUnit.mm
        ? config.heightMm.toDouble()
        : config.heightMm / 25.4;

    if (_widthController.text != _formatValue(width)) {
      _widthController.text = _formatValue(width);
    }
    if (_heightController.text != _formatValue(height)) {
      _heightController.text = _formatValue(height);
    }
  }

  String _formatValue(double value) {
    if (_unit == SizeUnit.mm) {
      return value.round().toString();
    } else {
      return value.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CanvasConfigProvider>(
      builder: (context, config, child) {
        _updateControllers(config);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: AppTheme.spacingLg),
              // Canvas Size
              _buildSizeSection(config),
              const SizedBox(height: AppTheme.spacingMd),
              // DPMM Settings
              _buildDpmmSection(config),
              const SizedBox(height: AppTheme.spacingMd),
              // Quick Presets
              _buildPresetsSection(config),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.bgTertiary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: AppTheme.accentPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Icon(Icons.crop_square_outlined, size: 16, color: AppTheme.accentPrimary),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Canvas Settings', style: AppTheme.heading2),
                Text('Label size and resolution', style: AppTheme.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeSection(CanvasConfigProvider config) {
    return _PropertySection(
      title: 'Label Size',
      children: [
        // Unit selector
        Row(
          children: [
            const Text('Unit:', style: AppTheme.caption),
            const SizedBox(width: AppTheme.spacingSm),
            _buildUnitButton(SizeUnit.mm, config),
            const SizedBox(width: AppTheme.spacingXs),
            _buildUnitButton(SizeUnit.inch, config),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),
        // Width & Height
        Row(
          children: [
            Expanded(
              child: _buildSizeField(
                label: 'Width',
                controller: _widthController,
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null && parsed > 0) {
                    final mm = _unit == SizeUnit.mm ? parsed.round() : (parsed * 25.4).round();
                    config.updateSize(mm.clamp(10, 500), config.heightMm);
                    widget.onChanged?.call();
                  }
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: _buildSizeField(
                label: 'Height',
                controller: _heightController,
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null && parsed > 0) {
                    final mm = _unit == SizeUnit.mm ? parsed.round() : (parsed * 25.4).round();
                    config.updateSize(config.widthMm, mm.clamp(10, 500));
                    widget.onChanged?.call();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSm),
        // Info
        Row(
          children: [
            const Icon(Icons.info_outline, size: 12, color: AppTheme.textTertiary),
            const SizedBox(width: AppTheme.spacingXs),
            Expanded(
              child: Text(
                '${config.widthMm} x ${config.heightMm} mm',
                style: AppTheme.caption.copyWith(color: AppTheme.textTertiary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnitButton(SizeUnit unit, CanvasConfigProvider config) {
    final isSelected = _unit == unit;
    return InkWell(
      onTap: () {
        setState(() {
          _unit = unit;
          _updateControllers(config);
        });
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingXs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentPrimary : AppTheme.surfaceDefault,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: isSelected ? AppTheme.accentPrimary : AppTheme.surfaceBorder,
          ),
        ),
        child: Text(
          unit.displayName,
          style: AppTheme.caption.copyWith(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSizeField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.caption),
        const SizedBox(height: AppTheme.spacingXs),
        TextField(
          controller: controller,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textPrimary),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            suffixText: _unit.displayName,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: AppTheme.spacingSm,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDpmmSection(CanvasConfigProvider config) {
    return _PropertySection(
      title: 'Resolution',
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Print Density (DPMM)', style: AppTheme.caption),
            const SizedBox(height: AppTheme.spacingXs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDefault,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Dpmm>(
                  value: config.dpmm,
                  isExpanded: true,
                  isDense: true,
                  dropdownColor: AppTheme.bgElevated,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textPrimary),
                  items: Dpmm.values.map((dpmm) {
                    return DropdownMenuItem<Dpmm>(
                      value: dpmm,
                      child: Text('${dpmm.value} dpmm (${dpmm.dpi} DPI)'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      config.updateDpmm(value);
                      widget.onChanged?.call();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetsSection(CanvasConfigProvider config) {
    return _PropertySection(
      title: 'Presets',
      children: [
        Wrap(
          spacing: AppTheme.spacingSm,
          runSpacing: AppTheme.spacingSm,
          children: [
            _buildPresetButton('50x25', 50, 25, config),
            _buildPresetButton('100x50', 100, 50, config),
            _buildPresetButton('100x100', 100, 100, config),
            _buildPresetButton('4"x6"', 102, 152, config),
            _buildPresetButton('4"x4"', 102, 102, config),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetButton(String label, int width, int height, CanvasConfigProvider config) {
    final isSelected = config.widthMm == width && config.heightMm == height;
    return InkWell(
      onTap: () {
        config.updateSize(width, height);
        widget.onChanged?.call();
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentPrimary.withOpacity(0.15) : AppTheme.surfaceDefault,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: isSelected ? AppTheme.accentPrimary : AppTheme.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.caption.copyWith(
            color: isSelected ? AppTheme.accentPrimary : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _PropertyEditor extends StatefulWidget {
  final BaseCanvasElement element;
  final VoidCallback? onChanged;

  const _PropertyEditor({
    super.key,
    required this.element,
    this.onChanged,
  });

  @override
  State<_PropertyEditor> createState() => _PropertyEditorState();
}

class _PropertyEditorState extends State<_PropertyEditor> {
  late TextEditingController _xController;
  late TextEditingController _yController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _xController = TextEditingController(text: widget.element.x.toString());
    _yController = TextEditingController(text: widget.element.y.toString());
    _widthController = TextEditingController(text: widget.element.width.toString());
    _heightController = TextEditingController(text: widget.element.height.toString());
  }

  @override
  void didUpdateWidget(covariant _PropertyEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.element != widget.element) {
      _initControllers();
    }
  }

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppTheme.spacingMd),
          _buildPositionSection(),
          const SizedBox(height: AppTheme.spacingMd),
          _buildSizeSection(),
          const SizedBox(height: AppTheme.spacingMd),
          ..._buildElementSpecificProperties(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String typeName = widget.element.runtimeType.toString().replaceAll('CanvasElement', '');
    IconData icon = _getElementIcon();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.bgTertiary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: AppTheme.accentPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, size: 16, color: AppTheme.accentPrimary),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(typeName, style: AppTheme.heading2),
                Text(
                  'Element Properties',
                  style: AppTheme.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getElementIcon() {
    if (widget.element is TextCanvasElement) return Icons.text_fields_outlined;
    if (widget.element is BoxCanvasElement) return Icons.crop_square_outlined;
    if (widget.element is BarcodeCanvasElement) return Icons.view_week_outlined;
    if (widget.element is QRCodeCanvasElement) return Icons.qr_code_2_outlined;
    if (widget.element is LineCanvasElement) return Icons.horizontal_rule;
    if (widget.element is DiagonalCanvasElement) return Icons.show_chart;
    if (widget.element is CircleCanvasElement) return Icons.circle_outlined;
    if (widget.element is EllipseCanvasElement) return Icons.panorama_fish_eye;
    return Icons.widgets_outlined;
  }

  Widget _buildPositionSection() {
    return _PropertySection(
      title: 'Position',
      children: [
        Row(
          children: [
            Expanded(
              child: _PropertyField(
                label: 'X',
                suffix: 'mm',
                controller: _xController,
                onChanged: (value) {
                  final x = int.tryParse(value);
                  if (x != null) {
                    widget.element.x = x;
                    _notifyChange();
                  }
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: _PropertyField(
                label: 'Y',
                suffix: 'mm',
                controller: _yController,
                onChanged: (value) {
                  final y = int.tryParse(value);
                  if (y != null) {
                    widget.element.y = y;
                    _notifyChange();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSizeSection() {
    return _PropertySection(
      title: 'Size',
      children: [
        Row(
          children: [
            Expanded(
              child: _PropertyField(
                label: 'W',
                suffix: 'mm',
                controller: _widthController,
                onChanged: (value) {
                  final w = int.tryParse(value);
                  if (w != null && w > 0) {
                    widget.element.width = w;
                    _notifyChange();
                  }
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: _PropertyField(
                label: 'H',
                suffix: 'mm',
                controller: _heightController,
                onChanged: (value) {
                  final h = int.tryParse(value);
                  if (h != null && h > 0) {
                    widget.element.height = h;
                    _notifyChange();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildElementSpecificProperties() {
    if (widget.element is TextCanvasElement) {
      return _buildTextProperties(widget.element as TextCanvasElement);
    } else if (widget.element is BoxCanvasElement) {
      return _buildBoxProperties(widget.element as BoxCanvasElement);
    } else if (widget.element is BarcodeCanvasElement) {
      return _buildBarcodeProperties(widget.element as BarcodeCanvasElement);
    } else if (widget.element is QRCodeCanvasElement) {
      return _buildQRCodeProperties(widget.element as QRCodeCanvasElement);
    } else if (widget.element is LineCanvasElement) {
      return _buildLineProperties(widget.element as LineCanvasElement);
    } else if (widget.element is DiagonalCanvasElement) {
      return _buildDiagonalProperties(widget.element as DiagonalCanvasElement);
    } else if (widget.element is CircleCanvasElement) {
      return _buildCircleProperties(widget.element as CircleCanvasElement);
    } else if (widget.element is EllipseCanvasElement) {
      return _buildEllipseProperties(widget.element as EllipseCanvasElement);
    }
    return [];
  }

  List<Widget> _buildTextProperties(TextCanvasElement element) {
    final textController = TextEditingController(text: element.text);
    final fontHeightController = TextEditingController(text: element.fontHeight.toString());
    final fontWidthController = TextEditingController(text: element.fontWidth.toString());

    return [
      _PropertySection(
        title: 'Content',
        children: [
          _PropertyField(
            label: 'Text',
            controller: textController,
            maxLines: 3,
            onChanged: (value) {
              element.text = value;
              _notifyChange();
            },
          ),
        ],
      ),
      const SizedBox(height: AppTheme.spacingMd),
      _PropertySection(
        title: 'Typography',
        children: [
          _PropertyDropdown<ZplFont>(
            label: 'Font',
            value: element.font,
            items: ZplFont.values,
            itemLabel: (f) => f.displayName,
            onChanged: (value) {
              if (value != null) {
                element.font = value;
                _notifyChange();
              }
            },
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            children: [
              Expanded(
                child: _PropertyField(
                  label: 'Height',
                  controller: fontHeightController,
                  onChanged: (value) {
                    element.fontHeight = (int.tryParse(value) ?? 20).clamp(10, 500);
                    _notifyChange();
                  },
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: _PropertyField(
                  label: 'Width',
                  controller: fontWidthController,
                  onChanged: (value) {
                    element.fontWidth = (int.tryParse(value) ?? 20).clamp(10, 500);
                    _notifyChange();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            children: [
              Expanded(
                child: _PropertyDropdown<ZplRotation>(
                  label: 'Rotation',
                  value: element.rotation,
                  items: ZplRotation.values,
                  itemLabel: (r) => r.displayName,
                  onChanged: (value) {
                    if (value != null) {
                      element.rotation = value;
                      _notifyChange();
                    }
                  },
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: _PropertyDropdown<TextAlignment>(
                  label: 'Align',
                  value: element.alignment,
                  items: TextAlignment.values,
                  itemLabel: (a) => a.displayName,
                  onChanged: (value) {
                    if (value != null) {
                      element.alignment = value;
                      _notifyChange();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: AppTheme.spacingMd),
      _buildBorderSection(
        showBorder: element.showBorder,
        thickness: element.borderThickness,
        onShowBorderChanged: (value) {
          element.showBorder = value;
          _notifyChange();
        },
        onThicknessChanged: (value) {
          element.borderThickness = value;
          _notifyChange();
        },
      ),
    ];
  }

  List<Widget> _buildBoxProperties(BoxCanvasElement element) {
    final thicknessController = TextEditingController(text: element.thickness.toString());

    return [
      _PropertySection(
        title: 'Appearance',
        children: [
          _PropertyField(
            label: 'Thickness',
            suffix: 'px',
            controller: thicknessController,
            onChanged: (value) {
              element.thickness = (int.tryParse(value) ?? 2).clamp(1, 100);
              _notifyChange();
            },
          ),
          const SizedBox(height: AppTheme.spacingSm),
          _PropertyDropdown<ZplRotation>(
            label: 'Rotation',
            value: element.rotation,
            items: ZplRotation.values,
            itemLabel: (r) => r.displayName,
            onChanged: (value) {
              if (value != null) {
                element.rotation = value;
                _notifyChange();
              }
            },
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildBarcodeProperties(BarcodeCanvasElement element) {
    final dataController = TextEditingController(text: element.data);
    final moduleWidthController = TextEditingController(text: element.moduleWidth.toString());
    final heightController = TextEditingController(text: element.barcodeHeight.toString());

    return [
      _PropertySection(
        title: 'Barcode',
        children: [
          _PropertyDropdown<BarcodeType>(
            label: 'Type',
            value: element.barcodeType,
            items: BarcodeType.values,
            itemLabel: (t) => t.displayName,
            onChanged: (value) {
              if (value != null) {
                element.barcodeType = value;
                _notifyChange();
              }
            },
          ),
          const SizedBox(height: AppTheme.spacingSm),
          _PropertyField(
            label: 'Data',
            controller: dataController,
            onChanged: (value) {
              element.data = value;
              _notifyChange();
            },
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            children: [
              Expanded(
                child: _PropertyField(
                  label: 'Module W',
                  controller: moduleWidthController,
                  onChanged: (value) {
                    element.moduleWidth = (int.tryParse(value) ?? 2).clamp(1, 10);
                    _notifyChange();
                  },
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: _PropertyField(
                  label: 'Height',
                  controller: heightController,
                  onChanged: (value) {
                    element.barcodeHeight = (int.tryParse(value) ?? 50).clamp(10, 500);
                    _notifyChange();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          _PropertyDropdown<ZplRotation>(
            label: 'Rotation',
            value: element.rotation,
            items: ZplRotation.values,
            itemLabel: (r) => r.displayName,
            onChanged: (value) {
              if (value != null) {
                element.rotation = value;
                _notifyChange();
              }
            },
          ),
          const SizedBox(height: AppTheme.spacingSm),
          _PropertyCheckbox(
            label: 'Show text below',
            value: element.showText,
            onChanged: (value) {
              element.showText = value;
              _notifyChange();
            },
          ),
        ],
      ),
      const SizedBox(height: AppTheme.spacingMd),
      _buildBorderSection(
        showBorder: element.showBorder,
        thickness: element.borderThickness,
        onShowBorderChanged: (value) {
          element.showBorder = value;
          _notifyChange();
        },
        onThicknessChanged: (value) {
          element.borderThickness = value;
          _notifyChange();
        },
      ),
    ];
  }

  List<Widget> _buildQRCodeProperties(QRCodeCanvasElement element) {
    final dataController = TextEditingController(text: element.data);
    final magController = TextEditingController(text: element.magnification.toString());

    return [
      _PropertySection(
        title: 'QR Code',
        children: [
          _PropertyField(
            label: 'Data',
            controller: dataController,
            maxLines: 3,
            onChanged: (value) {
              element.data = value;
              _notifyChange();
            },
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            children: [
              Expanded(
                child: _PropertyField(
                  label: 'Size',
                  controller: magController,
                  onChanged: (value) {
                    element.magnification = (int.tryParse(value) ?? 4).clamp(1, 10);
                    _notifyChange();
                  },
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: _PropertyDropdown<ZplRotation>(
                  label: 'Rotation',
                  value: element.rotation,
                  items: ZplRotation.values,
                  itemLabel: (r) => r.displayName,
                  onChanged: (value) {
                    if (value != null) {
                      element.rotation = value;
                      _notifyChange();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          _PropertyDropdown<QRErrorCorrection>(
            label: 'Error Correction',
            value: element.errorCorrection,
            items: QRErrorCorrection.values,
            itemLabel: (e) => e.displayName,
            onChanged: (value) {
              if (value != null) {
                element.errorCorrection = value;
                _notifyChange();
              }
            },
          ),
        ],
      ),
      const SizedBox(height: AppTheme.spacingMd),
      _buildBorderSection(
        showBorder: element.showBorder,
        thickness: element.borderThickness,
        onShowBorderChanged: (value) {
          element.showBorder = value;
          _notifyChange();
        },
        onThicknessChanged: (value) {
          element.borderThickness = value;
          _notifyChange();
        },
      ),
    ];
  }

  List<Widget> _buildLineProperties(LineCanvasElement element) {
    final thicknessController = TextEditingController(text: element.thickness.toString());

    return [
      _PropertySection(
        title: 'Line',
        children: [
          _PropertyDropdown<LineOrientation>(
            label: 'Orientation',
            value: element.orientation,
            items: LineOrientation.values,
            itemLabel: (o) => o.displayName,
            onChanged: (value) {
              if (value != null) {
                element.orientation = value;
                _notifyChange();
              }
            },
          ),
          const SizedBox(height: AppTheme.spacingSm),
          _PropertyField(
            label: 'Thickness',
            suffix: 'px',
            controller: thicknessController,
            onChanged: (value) {
              element.thickness = (int.tryParse(value) ?? 2).clamp(1, 20);
              _notifyChange();
            },
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildDiagonalProperties(DiagonalCanvasElement element) {
    final thicknessController = TextEditingController(text: element.thickness.toString());

    return [
      _PropertySection(
        title: 'Diagonal Line',
        children: [
          _PropertyDropdown<DiagonalOrientation>(
            label: 'Orientation',
            value: element.orientation,
            items: DiagonalOrientation.values,
            itemLabel: (o) => o.displayName,
            onChanged: (value) {
              if (value != null) {
                element.orientation = value;
                _notifyChange();
              }
            },
          ),
          const SizedBox(height: AppTheme.spacingSm),
          _PropertyField(
            label: 'Thickness',
            suffix: 'px',
            controller: thicknessController,
            onChanged: (value) {
              element.thickness = (int.tryParse(value) ?? 2).clamp(1, 20);
              _notifyChange();
            },
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildCircleProperties(CircleCanvasElement element) {
    final diameterController = TextEditingController(text: element.diameter.toString());
    final thicknessController = TextEditingController(text: element.thickness.toString());

    return [
      _PropertySection(
        title: 'Circle',
        children: [
          _PropertyField(
            label: 'Diameter',
            suffix: 'mm',
            controller: diameterController,
            onChanged: (value) {
              final diameter = (int.tryParse(value) ?? 20).clamp(5, 500);
              element.diameter = diameter;
              element.width = diameter;
              element.height = diameter;
              _notifyChange();
            },
          ),
          const SizedBox(height: AppTheme.spacingSm),
          _PropertyField(
            label: 'Thickness',
            suffix: 'px',
            controller: thicknessController,
            onChanged: (value) {
              element.thickness = (int.tryParse(value) ?? 2).clamp(1, 20);
              _notifyChange();
            },
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildEllipseProperties(EllipseCanvasElement element) {
    final thicknessController = TextEditingController(text: element.thickness.toString());

    return [
      _PropertySection(
        title: 'Ellipse',
        children: [
          _PropertyField(
            label: 'Thickness',
            suffix: 'px',
            controller: thicknessController,
            onChanged: (value) {
              element.thickness = (int.tryParse(value) ?? 2).clamp(1, 20);
              _notifyChange();
            },
          ),
        ],
      ),
    ];
  }

  Widget _buildBorderSection({
    required bool showBorder,
    required int thickness,
    required Function(bool) onShowBorderChanged,
    required Function(int) onThicknessChanged,
  }) {
    return _PropertySection(
      title: 'Border',
      children: [
        _PropertyCheckbox(
          label: 'Show border',
          value: showBorder,
          onChanged: onShowBorderChanged,
        ),
        if (showBorder) ...[
          const SizedBox(height: AppTheme.spacingSm),
          _PropertyField(
            label: 'Thickness',
            suffix: 'px',
            controller: TextEditingController(text: thickness.toString()),
            onChanged: (value) {
              onThicknessChanged((int.tryParse(value) ?? 2).clamp(1, 10));
            },
          ),
        ],
      ],
    );
  }
}

class _PropertySection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _PropertySection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTheme.caption.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: AppTheme.bgTertiary,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}

class _PropertyField extends StatelessWidget {
  final String label;
  final String? suffix;
  final TextEditingController controller;
  final int maxLines;
  final Function(String) onChanged;

  const _PropertyField({
    required this.label,
    this.suffix,
    required this.controller,
    this.maxLines = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.caption),
        const SizedBox(height: AppTheme.spacingXs),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            suffixText: suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: AppTheme.spacingSm,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _PropertyDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final Function(T?) onChanged;

  const _PropertyDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.caption),
        const SizedBox(height: AppTheme.spacingXs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDefault,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.surfaceBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              isDense: true,
              dropdownColor: AppTheme.bgElevated,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textPrimary),
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _PropertyCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;

  const _PropertyCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(label, style: AppTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
