part of main;

/// A mouse handler for translating the view port.
class LineRemover implements plotter.IMouseHandle {
  /// The plotter this mouse handle is changing.
  qtPlot.QuadTreePlotter _plot;

  qtPlot.QuadTree _plotItem;

  qt.QuadTree _tree;

  /// Indicates if mouse panning is enabled or not.
  bool _enabled;

  /// The mouse button pressed.
  final plotter.MouseButtonState _state;
  bool _mouseDown;
  bool _trimTree;
  plotter.Lines _tempLine;

  /// Creates a new mouse pan handler.
  LineRemover(this._tree, this._plot, this._plotItem, this._state, this._trimTree) {
    _enabled = true;
    _mouseDown = false;
    _tempLine = _plot.addLines([])
      ..addPointSize(5.0)
      ..addDirected(true)
      ..addColor(1.0, 0.0, 0.0);
  }

  /// Indicates of the point adder tool is enabled or not.
  bool get enabled => _enabled;
  set enabled(bool value) => _enabled = value;

  qt.EdgeNode _findEdge(plotter.MouseEvent e) {
    plotter.Transformer trans = e.projection.mul(_plot.view);
    int x = trans.untransformX(e.x).round();
    int y = trans.untransformY(e.window.ymax - e.y).round();
    return _tree.findNearestEdge(new qt.Point(x, y));
  }

  /// handles mouse down.
  void mouseDown(plotter.MouseEvent e) {
    if (_enabled && e.state.equals(_state)) {
      _mouseDown = true;
      qt.EdgeNode edge = _findEdge(e);
      if (edge != null)
        _tempLine.add([edge.start.x.toDouble(), edge.start.y.toDouble(), edge.end.x.toDouble(), edge.end.y.toDouble()]);
      e.redraw = true;
    }
  }

  /// handles mouse moved.
  void mouseMove(plotter.MouseEvent e) {
    if (_mouseDown) {
      _tempLine.clear();
      qt.EdgeNode edge = _findEdge(e);
      if (edge != null)
        _tempLine.add([edge.start.x.toDouble(), edge.start.y.toDouble(), edge.end.x.toDouble(), edge.end.y.toDouble()]);
      e.redraw = true;
    }
  }

  /// handles mouse up.
  void mouseUp(plotter.MouseEvent e) {
    if (_mouseDown) {
      qt.EdgeNode edge = _findEdge(e);
      if (edge != null) _tree.removeEdge(edge, _trimTree);
      _mouseDown = false;
      _tempLine.clear();
      _plotItem.updateTree();
      e.redraw = true;
    }
  }
}
