import 'package:flutter/material.dart';
import 'package:zpl_designer/core/dpmm.dart';

class CanvasConfigProvider extends ChangeNotifier {
  int _widthMm;
  int _heightMm;
  Dpmm _dpmm;
  bool _showGrid;

  CanvasConfigProvider({
    required int widthMm,
    required int heightMm,
    Dpmm dpmm = Dpmm.dpmm8,
    bool showGrid = true,
  }) : _widthMm = widthMm,
       _heightMm = heightMm,
       _dpmm = dpmm,
       _showGrid = showGrid;

  int get widthMm => _widthMm;
  int get heightMm => _heightMm;
  Dpmm get dpmm => _dpmm;
  bool get showGrid => _showGrid;

  set widthMm(int value) {
    if (_widthMm != value) {
      _widthMm = value;
      notifyListeners();
    }
  }

  set heightMm(int value) {
    if (_heightMm != value) {
      _heightMm = value;
      notifyListeners();
    }
  }

  set dpmm(Dpmm value) {
    if (_dpmm != value) {
      _dpmm = value;
      notifyListeners();
    }
  }

  set showGrid(bool value) {
    if (_showGrid != value) {
      _showGrid = value;
      notifyListeners();
    }
  }

  void toggleGrid() {
    _showGrid = !_showGrid;
    notifyListeners();
  }

  void updateSize(int width, int height) {
    bool changed = false;
    if (_widthMm != width) {
      _widthMm = width;
      changed = true;
    }
    if (_heightMm != height) {
      _heightMm = height;
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  void updateDpmm(Dpmm value) {
    if (_dpmm != value) {
      _dpmm = value;
      notifyListeners();
    }
  }
}
