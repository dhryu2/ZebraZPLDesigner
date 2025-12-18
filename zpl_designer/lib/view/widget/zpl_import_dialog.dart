import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:zpl_designer/core/app_theme.dart';
import 'package:zpl_designer/core/base_canvas_element.dart';
import 'package:zpl_designer/core/dpmm.dart';
import 'package:zpl_designer/core/zpl_parser.dart';

class ZplImportDialog extends StatefulWidget {
  final Dpmm dpmm;

  const ZplImportDialog({
    super.key,
    required this.dpmm,
  });

  @override
  State<ZplImportDialog> createState() => _ZplImportDialogState();
}

class _ZplImportDialogState extends State<ZplImportDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<BaseCanvasElement>? _parsedElements;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  void _parseZpl() {
    final zplCode = _controller.text.trim();
    if (zplCode.isEmpty) {
      setState(() {
        _errorMessage = null;
        _parsedElements = null;
      });
      return;
    }

    if (!zplCode.contains('^XA') || !zplCode.contains('^XZ')) {
      setState(() {
        _errorMessage = 'Invalid ZPL code. ^XA and ^XZ are required.';
        _parsedElements = null;
      });
      return;
    }

    try {
      final parser = ZplParser(dpmm: widget.dpmm);
      final elements = parser.parse(zplCode);

      setState(() {
        if (elements.isEmpty) {
          _errorMessage = 'No parseable elements found. Supported commands: ^GB (box), ^A/^FD (text), ^BC/^B3/^BE/^BU (barcode), ^BQ (QR code)';
          _parsedElements = null;
        } else {
          _errorMessage = null;
          _parsedElements = elements;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Parse error: $e';
        _parsedElements = null;
      });
    }
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      _controller.text = clipboardData!.text!;
      _parseZpl();
    }
  }

  Future<void> _loadFromFile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Open ZPL File',
        type: FileType.custom,
        allowedExtensions: ['txt', 'zpl'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.single.path;
        if (filePath != null) {
          final file = File(filePath);
          final content = await file.readAsString();

          _controller.text = content;
          _parseZpl();
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to read file: $e';
        _parsedElements = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
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
        height: 560,
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
                  child: const Icon(Icons.file_upload_outlined, size: 20, color: AppTheme.accentPrimary),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Import ZPL Code', style: AppTheme.heading1),
                    Text('Paste or load ZPL code to import', style: AppTheme.caption),
                  ],
                ),
                const Spacer(),
                _buildInfoChip('${widget.dpmm.value} dpmm'),
              ],
            ),
            const SizedBox(height: AppTheme.spacingLg),
            // Quick actions
            Row(
              children: [
                _buildActionButton(
                  icon: Icons.folder_open_outlined,
                  label: 'Open File',
                  onPressed: _isLoading ? null : _loadFromFile,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                _buildActionButton(
                  icon: Icons.paste_outlined,
                  label: 'Paste',
                  onPressed: _isLoading ? null : _pasteFromClipboard,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                _buildActionButton(
                  icon: Icons.clear_outlined,
                  label: 'Clear',
                  onPressed: () {
                    _controller.clear();
                    _parseZpl();
                  },
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            // Code input
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(
                        fontFamily: 'Consolas, Monaco, monospace',
                        fontSize: 12,
                        color: Color(0xFF98D19E),
                        height: 1.5,
                      ),
                      decoration: InputDecoration(
                        hintText: '^XA\n^FO50,50^GB200,100,3^FS\n^FO50,200^A0N,30,30^FDHello World^FS\n^XZ',
                        hintStyle: TextStyle(
                          fontFamily: 'Consolas, Monaco, monospace',
                          fontSize: 12,
                          color: AppTheme.textDisabled.withOpacity(0.5),
                          height: 1.5,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(AppTheme.spacingMd),
                      ),
                      onChanged: (_) => _parseZpl(),
                    ),
                  ),
                  if (_isLoading)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: AppTheme.accentPrimary),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            // Status
            if (_errorMessage != null)
              _buildStatusBox(
                icon: Icons.error_outline,
                message: _errorMessage!,
                color: AppTheme.accentError,
              ),
            if (_parsedElements != null)
              _buildStatusBox(
                icon: Icons.check_circle_outline,
                message: 'Found ${_parsedElements!.length} elements',
                color: AppTheme.accentSuccess,
                child: Wrap(
                  spacing: AppTheme.spacingXs,
                  runSpacing: AppTheme.spacingXs,
                  children: _parsedElements!.map((e) {
                    final typeName = e.runtimeType.toString().replaceAll('CanvasElement', '');
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSm,
                        vertical: AppTheme.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentSuccess.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Text(
                        typeName,
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.accentSuccess,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: AppTheme.spacingLg),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: AppTheme.surfaceBorder),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingLg,
                      vertical: AppTheme.spacingMd,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                ElevatedButton.icon(
                  onPressed: _parsedElements != null && _parsedElements!.isNotEmpty
                      ? () => Navigator.of(context).pop(_parsedElements)
                      : null,
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Import'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPrimary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.surfaceDefault,
                    disabledForegroundColor: AppTheme.textDisabled,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingLg,
                      vertical: AppTheme.spacingMd,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.textSecondary,
        side: const BorderSide(color: AppTheme.surfaceBorder),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
      ),
    );
  }

  Widget _buildStatusBox({
    required IconData icon,
    required String message,
    required Color color,
    Widget? child,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Text(
                  message,
                  style: AppTheme.bodySmall.copyWith(color: color),
                ),
              ),
            ],
          ),
          if (child != null) ...[
            const SizedBox(height: AppTheme.spacingSm),
            child,
          ],
        ],
      ),
    );
  }
}
