part of main;

/// A mouse handler for translating the view port.
class PointRemover implements plotter.IMouseHandle {
  /// The plotter this mouse handle is changing.
  qtPlot.QuadTreePlotter _plot;

  qtPlot.QuadTree _plotItem;

  qt.QuadTree _tree;

  /// Indicates if mouse panning is enabled or not.
  bool _enabled;

  /// The mouse button pressed.
  final plotter.MouseButtonState _state;
  bool _mouseDown;
  plotter.Points _tempPoint;

  /// Creates a new mouse pan handler.
  PointRemover(this._tree, this._plot, this._plotItem, this._state) {
    _enabled = true;
    _mouseDown = false;
    _tempPoint = _plot.addPoints([])
      ..addPointSize(5.0)
      ..addColor(1.0, 0.0, 0.0);
  }

  /// Indicates of the point remover tool is enabled or not.
  bool get enabled => _enabled;
  set enabled(bool value) => _enabled = value;

  qt.PointNode _findNearPoint(plotter.MouseEvent e) {
    plotter.Transformer trans = e.projection.mul(_plot.view);
    int msx = trans.untransformX(e.x).round();
    int msy = trans.untransformY(e.window.ymax - e.y).round();
    qt.BaseNode node = _tree.nodeContaining(new qt.Point(msx, msy));
    if (node is qt.PointNode) return node;
    return null;
  }

  /// handles mouse down.
  void mouseDown(plotter.MouseEvent e) {
    if (_enabled && e.state.equals(_state)) {
      _mouseDown = true;
      qt.PointNode node = _findNearPoint(e);
      if (node != null) _tempPoint.add([node.point.x.toDouble(), node.point.y.toDouble()]);
      e.redraw = true;
    }
  }

  /// handles mouse moved.
  void mouseMove(plotter.MouseEvent e) {
    if (_mouseDown) {
      _tempPoint.clear();
      qt.PointNode node = _findNearPoint(e);
      if (node != null) _tempPoint.add([node.point.x.toDouble(), node.point.y.toDouble()]);
      e.redraw = true;
    }
  }

  /// handles mouse up.
  void mouseUp(plotter.MouseEvent e) {
    if (_mouseDown) {
      qt.PointNode node = _findNearPoint(e);
      if (node != null) _tree.removePoint(node);
      _mouseDown = false;
      _tempPoint.clear();
      _plotItem.updateTree();
      e.redraw = true;
    }
  }
}
