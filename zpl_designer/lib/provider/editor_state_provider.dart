import 'package:flutter/material.dart';
import 'package:zpl_designer/core/base_canvas_element.dart';

/// Editor state management - selection, zoom, history
class EditorStateProvider extends ChangeNotifier {
  // Selection
  BaseCanvasElement? _selectedElement;
  BaseCanvasElement? get selectedElement => _selectedElement;

  void selectElement(BaseCanvasElement? element) {
    if (_selectedElement != element) {
      _selectedElement = element;
      notifyListeners();
    }
  }

  void clearSelection() {
    if (_selectedElement != null) {
      _selectedElement = null;
      notifyListeners();
    }
  }

  // Zoom
  double _zoom = 1.0;
  double get zoom => _zoom;

  static const double minZoom = 0.25;
  static const double maxZoom = 4.0;

  void setZoom(double value) {
    final newZoom = value.clamp(minZoom, maxZoom);
    if (_zoom != newZoom) {
      _zoom = newZoom;
      notifyListeners();
    }
  }

  void zoomIn() {
    setZoom(_zoom * 1.25);
  }

  void zoomOut() {
    setZoom(_zoom / 1.25);
  }

  void resetZoom() {
    setZoom(1.0);
  }

  // Zoom to fit
  void zoomToFit() {
    setZoom(1.0);
  }

  // History (Undo/Redo)
  final List<EditorAction> _undoStack = [];
  final List<EditorAction> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void pushAction(EditorAction action) {
    _undoStack.add(action);
    _redoStack.clear();
    notifyListeners();
  }

  EditorAction? undo() {
    if (_undoStack.isEmpty) return null;
    final action = _undoStack.removeLast();
    _redoStack.add(action);
    notifyListeners();
    return action;
  }

  EditorAction? redo() {
    if (_redoStack.isEmpty) return null;
    final action = _redoStack.removeLast();
    _undoStack.add(action);
    notifyListeners();
    return action;
  }

  void clearHistory() {
    _undoStack.clear();
    _redoStack.clear();
    notifyListeners();
  }

  // Clipboard
  BaseCanvasElement? _clipboard;
  BaseCanvasElement? get clipboard => _clipboard;

  void copyElement(BaseCanvasElement element) {
    _clipboard = element.copyWith();
    notifyListeners();
  }

  bool get canPaste => _clipboard != null;
}

/// Represents an action that can be undone/redone
class EditorAction {
  final EditorActionType type;
  final BaseCanvasElement element;
  final BaseCanvasElement? previousState;
  final int? index;

  EditorAction({
    required this.type,
    required this.element,
    this.previousState,
    this.index,
  });
}

enum EditorActionType {
  add,
  remove,
  move,
  resize,
  modify,
}
