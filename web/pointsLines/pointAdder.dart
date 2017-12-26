part of main;

/// A mouse handler for adding points.
class PointAdder implements plotter.IMouseHandle {
  final plotter.MouseButtonState _state;
  qtPlot.QuadTreePlotter _plot;
  qtPlot.QuadTree _plotItem;
  qt.QuadTree _tree;
  bool _enabled;
  bool _mouseDown;
  plotter.Points _tempPoint;

  /// Creates a new mouse handler for adding points.
  PointAdder(this._tree, this._plot, this._plotItem, this._state) {
    _enabled = true;
    _mouseDown = false;
    _tempPoint = _plot.addPoints([])
      ..addPointSize(5.0)
      ..addColor(1.0, 0.0, 0.0);
  }

  /// Indicates of the point adder tool is enabled or not.
  bool get enabled => _enabled;
  set enabled(bool value) => _enabled = value;

  /// Translates the mouse location into the tree space based on the view.
  List<double> _transMouse(plotter.MouseEvent e) {
    plotter.Transformer trans = e.projection.mul(_plot.view);
    return [trans.untransformX(e.x), trans.untransformY(e.window.ymax - e.y)];
  }

  /// handles mouse down.
  void mouseDown(plotter.MouseEvent e) {
    if (_enabled && e.state.equals(_state)) {
      _mouseDown = true;
      List<double> loc = _transMouse(e);
      _tempPoint.add([loc[0].roundToDouble(), loc[1].roundToDouble()]);
      e.redraw = true;
    }
  }

  /// handles mouse moved.
  void mouseMove(plotter.MouseEvent e) {
    if (_mouseDown) {
      List<double> loc = _transMouse(e);
      _tempPoint.set(0, [loc[0].roundToDouble(), loc[1].roundToDouble()]);
      e.redraw = true;
    }
  }

  /// handles mouse up.
  void mouseUp(plotter.MouseEvent e) {
    if (_mouseDown) {
      List<double> loc = _transMouse(e);
      int msx = loc[0].round();
      int msy = loc[1].round();
      _tree.insertPoint(new qt.Point(msx, msy));
      _mouseDown = false;
      _tempPoint.clear();
      _plotItem.updateTree();
      e.redraw = true;
    }
  }
}
