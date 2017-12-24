part of main;

/// A mouse handler for translating the view port.
class LineAdder implements plotter.IMouseHandle {
  /// The plotter this mouse handle is changing.
  qtPlot.QuadTreePlotter _plot;

  qtPlot.QuadTree _plotItem;

  qt.QuadTree _tree;

  /// Indicates if mouse panning is enabled or not.
  bool _enabled;

  /// The mouse button pressed.
  final plotter.MouseButtonState _state;
  bool _mouseDown;
  double _startX;
  double _startY;
  plotter.Lines _tempLine;

  /// Creates a new mouse pan handler.
  LineAdder(this._tree, this._plot, this._plotItem, this._state) {
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

  List<double> _transMouse(plotter.MouseEvent e) {
    plotter.Transformer trans = e.projection.mul(_plot.view);
    return [trans.untransformX(e.x), trans.untransformY(e.window.ymax - e.y)];
  }

  /// handles mouse down.
  void mouseDown(plotter.MouseEvent e) {
    if (_enabled && e.state.equals(_state)) {
      _mouseDown = true;
      List<double> loc = _transMouse(e);
      _startX = loc[0].roundToDouble();
      _startY = loc[1].roundToDouble();
      _tempLine.add([_startX, _startY, _startX, _startY]);
      e.redraw = true;
    }
  }

  /// handles mouse moved.
  void mouseMove(plotter.MouseEvent e) {
    if (_mouseDown) {
      List<double> loc = _transMouse(e);
      _tempLine.set(0, [_startX, _startY, loc[0].roundToDouble(), loc[1].roundToDouble()]);
      e.redraw = true;
    }
  }

  /// handles mouse up.
  void mouseUp(plotter.MouseEvent e) {
    if (_mouseDown) {
      List<double> loc = _transMouse(e);
      qt.Point pnt1 = new qt.Point(_startX.round(), _startY.round());
      qt.Point pnt2 = new qt.Point(loc[0].round(), loc[1].round());
      _tree.insertEdge(new qt.Edge(pnt1, pnt2));
      _mouseDown = false;
      _tempLine.clear();
      _plotItem.updateTree();
      e.redraw = true;
    }
  }
}
