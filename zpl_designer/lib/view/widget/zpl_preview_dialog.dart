import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zpl_designer/core/app_theme.dart';
import 'package:zpl_designer/core/base_canvas_element.dart';
import 'package:zpl_designer/core/dpmm.dart';

class ZplPreviewDialog extends StatefulWidget {
  final List<BaseCanvasElement> elements;
  final int widthMm;
  final int heightMm;
  final Dpmm dpmm;

  const ZplPreviewDialog({
    super.key,
    required this.elements,
    required this.widthMm,
    required this.heightMm,
    required this.dpmm,
  });

  @override
  State<ZplPreviewDialog> createState() => _ZplPreviewDialogState();
}

class _ZplPreviewDialogState extends State<ZplPreviewDialog> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPreview();
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

  Future<void> _loadPreview() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final zplCode = _generateZplCode();

      final dpmm = widget.dpmm.value;
      final widthInches = widget.widthMm / 25.4;
      final heightInches = widget.heightMm / 25.4;

      final url = Uri.parse(
        'http://api.labelary.com/v1/printers/${dpmm}dpmm/labels/${widthInches.toStringAsFixed(2)}x${heightInches.toStringAsFixed(2)}/0/',
      );

      final response = await http.post(
        url,
        headers: {
          'Accept': 'image/png',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: zplCode,
      );

      if (response.statusCode == 200) {
        setState(() {
          _imageBytes = response.bodyBytes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'API Error: ${response.statusCode}\n${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load preview: $e';
        _isLoading = false;
      });
    }
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
        width: 560,
        height: 600,
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
                  child: const Icon(Icons.visibility_outlined, size: 20, color: AppTheme.accentPrimary),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Label Preview', style: AppTheme.heading1),
                    Text('Rendered via Labelary API', style: AppTheme.caption),
                  ],
                ),
                const Spacer(),
                _buildInfoChip('${widget.widthMm}x${widget.heightMm}mm'),
                const SizedBox(width: AppTheme.spacingSm),
                _buildInfoChip('${widget.dpmm.value} dpmm'),
              ],
            ),
            const SizedBox(height: AppTheme.spacingLg),
            // Preview container
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: _buildPreviewContent(),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            // Info row
            Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: AppTheme.textTertiary),
                const SizedBox(width: AppTheme.spacingXs),
                Expanded(
                  child: Text(
                    'Use mouse wheel to zoom. Preview is generated by Labelary API.',
                    style: AppTheme.caption.copyWith(color: AppTheme.textTertiary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingLg),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _loadPreview,
                  icon: const Icon(Icons.refresh_outlined, size: 18),
                  label: const Text('Refresh'),
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
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: AppTheme.accentPrimary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              'Generating preview...',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.accentError.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 32,
                  color: AppTheme.accentError,
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Text(
                'Preview Failed',
                style: AppTheme.heading2.copyWith(color: AppTheme.textPrimary),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              OutlinedButton.icon(
                onPressed: _loadPreview,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try Again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accentPrimary,
                  side: const BorderSide(color: AppTheme.accentPrimary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLg,
                    vertical: AppTheme.spacingSm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd - 1),
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                child: Image.memory(
                  _imageBytes!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
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
