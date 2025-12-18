import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:zpl_designer/core/app_theme.dart';
import 'package:zpl_designer/core/base_canvas_element.dart';
import 'package:zpl_designer/core/dpmm.dart';

class ZplExportDialog extends StatefulWidget {
  final List<BaseCanvasElement> elements;
  final int widthMm;
  final int heightMm;
  final Dpmm dpmm;

  const ZplExportDialog({
    super.key,
    required this.elements,
    required this.widthMm,
    required this.heightMm,
    required this.dpmm,
  });

  @override
  State<ZplExportDialog> createState() => _ZplExportDialogState();
}

class _ZplExportDialogState extends State<ZplExportDialog> {
  late String _zplCode;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _zplCode = _generateZplCode();
  }

  String _generateZplCode() {
    final buffer = StringBuffer();

    buffer.writeln('^XA');

    final widthDots = widget.dpmm.mmToDot(widget.widthMm.toDouble());
    final heightDots = widget.dpmm.mmToDot(widget.heightMm.toDouble());
    buffer.writeln('^PW$widthDots');
    buffer.writeln('^LL$heightDots');

    final sortedElements = List<BaseCanvasElement>.from(widget.elements)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));
    for (final element in sortedElements) {
      final xDots = widget.dpmm.mmToDot(element.x.toDouble());
      final yDots = widget.dpmm.mmToDot(element.y.toDouble());
      final elementWidthDots = widget.dpmm.mmToDot(element.width.toDouble());
      final elementHeightDots = widget.dpmm.mmToDot(element.height.toDouble());

      final originalX = element.x;
      final originalY = element.y;
      final originalWidth = element.width;
      final originalHeight = element.height;

      element.x = xDots;
      element.y = yDots;
      element.width = elementWidthDots;
      element.height = elementHeightDots;

      buffer.writeln(element.conversionZPLCode());

      element.x = originalX;
      element.y = originalY;
      element.width = originalWidth;
      element.height = originalHeight;
    }

    buffer.writeln('^XZ');

    return buffer.toString();
  }

  Future<void> _saveToFile() async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save ZPL File',
        fileName: 'label.txt',
        type: FileType.custom,
        allowedExtensions: ['txt', 'zpl'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsString(_zplCode);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File saved: ${file.path}', style: AppTheme.bodySmall.copyWith(color: Colors.white)),
              backgroundColor: AppTheme.accentSuccess,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
              margin: const EdgeInsets.all(AppTheme.spacingMd),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e', style: AppTheme.bodySmall.copyWith(color: Colors.white)),
            backgroundColor: AppTheme.accentError,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
            margin: const EdgeInsets.all(AppTheme.spacingMd),
          ),
        );
      }
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _zplCode));
    setState(() {
      _copied = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.bgSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        side: const BorderSide(color: AppTheme.surfaceBorder),
      ),
      child: Container(
        width: 640,
        height: 520,
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: const Icon(Icons.code, size: 20, color: AppTheme.accentPrimary),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Export ZPL Code', style: AppTheme.heading1),
                    Text(
                      '${widget.elements.length} elements',
                      style: AppTheme.caption,
                    ),
                  ],
                ),
                const Spacer(),
                _buildInfoChip('${widget.widthMm}x${widget.heightMm}mm'),
                const SizedBox(width: AppTheme.spacingSm),
                _buildInfoChip('${widget.dpmm.value} dpmm'),
              ],
            ),
            const SizedBox(height: AppTheme.spacingLg),
            // Code container
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  children: [
                    // Code header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                        vertical: AppTheme.spacingSm,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppTheme.surfaceBorder)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.terminal, size: 14, color: AppTheme.textTertiary),
                          const SizedBox(width: AppTheme.spacingSm),
                          Text('ZPL Code', style: AppTheme.caption.copyWith(fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Text(
                            '${_zplCode.split('\n').length} lines',
                            style: AppTheme.caption,
                          ),
                        ],
                      ),
                    ),
                    // Code content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        child: SelectableText(
                          _zplCode,
                          style: const TextStyle(
                            fontFamily: 'Consolas, Monaco, monospace',
                            fontSize: 12,
                            color: Color(0xFF98D19E),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _copyToClipboard,
                    icon: Icon(_copied ? Icons.check : Icons.copy_outlined, size: 18),
                    label: Text(_copied ? 'Copied!' : 'Copy to Clipboard'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _copied ? AppTheme.accentSuccess : AppTheme.textPrimary,
                      side: BorderSide(
                        color: _copied ? AppTheme.accentSuccess : AppTheme.surfaceBorder,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saveToFile,
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Save to File'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.surfaceBorder),
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingXl,
                      vertical: AppTheme.spacingMd,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppTheme.bgTertiary,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(label, style: AppTheme.caption),
    );
  }
}
