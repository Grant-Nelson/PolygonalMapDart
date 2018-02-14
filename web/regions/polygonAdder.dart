part of main;

/// A mouse handler for adding lines.
class PolygonAdder implements plotter.IMouseHandle {
  final plotter.MouseButtonState _addPointState;
  final plotter.MouseButtonState _finishRegionState;
  qtPlot.QuadTreePlotter _plot;
  qtPlot.QuadTree _plotItem;
  maps.Regions _regions;
  bool _enabled;
  int _regionId;
  bool _mouseDown;
  List<qt.Point> _points;
  plotter.Lines _tempLines;

  /// Creates a new mouse handler for adding lines.
  PolygonAdder(this._regions, this._plot, this._plotItem, this._addPointState, this._finishRegionState) {
    _enabled = true;
    _regionId = 1;
    _mouseDown = false;
    _points = new List<qt.Point>();
    _tempLines = _plot.addLines([])
      ..addPointSize(5.0)
      ..addDirected(true)
      ..addColor(1.0, 0.0, 0.0);
  }

  /// Indicates of the point adder tool is enabled or not.
  bool get enabled => _enabled;
  set enabled(bool value) => _enabled = value;

  /// Is the region Id which is about to be applied.
  int get regionId => _regionId;
  set regionId(int value) => _regionId = value;

  /// Prints the region in the buffer.
  void _printRegion() {
    String result = "";
    bool first = true;
    for (qt.Point pnt in _points) {
      if (first) {
        result += "{";
        first = false;
      } else {
        result += ", ";
      }
      result += "[${pnt.x}, ${pnt.y}]";
    }
    print(result + "}");
  }

  /// Finished and inserts a region.
  void finishRegion() {
    if (_points.length > 0) {
      _printRegion();
      _regions.addRegion(_regionId, _points);
    }
    _plotItem.updateTree();
    _points.clear();
    _tempLines.clear();
  }

  /// Translates the mouse location into the tree space based on the view.
  List<double> _transMouse(plotter.MouseEvent e) {
    plotter.Transformer trans = e.projection.mul(_plot.view);
    return [trans.untransformX(e.x), trans.untransformY(e.window.ymax - e.y)];
  }

  /// handles mouse down.
  void mouseDown(plotter.MouseEvent e) {
    if (_enabled) {
      if (e.state.equals(_finishRegionState)) {
        finishRegion();
        e.redraw = true;
      } else if (e.state.equals(_addPointState)) {
        _mouseDown = true;
        List<double> loc = _transMouse(e);
        double x = loc[0].roundToDouble();
        double y = loc[1].roundToDouble();
        if (_tempLines.count > 0) {
          List<double> last = _tempLines.get(_tempLines.count - 1, 1);
          _tempLines.add([last[2], last[3], x, y]);
        } else {
          _tempLines.add([x, y, x, y]);
          _points.add(new qt.Point(x.round(), y.round()));
        }
        e.redraw = true;
      }
    }
  }

  /// handles mouse moved.
  void mouseMove(plotter.MouseEvent e) {
    if (_mouseDown) {
      List<double> loc = _transMouse(e);
      List<double> last = _tempLines.get(_tempLines.count - 1, 1);
      _tempLines.set(_tempLines.count - 1, [last[0], last[1], loc[0].roundToDouble(), loc[1].roundToDouble()]);
      e.redraw = true;
    }
  }

  /// handles mouse up.
  void mouseUp(plotter.MouseEvent e) {
    if (_mouseDown) {
      List<double> loc = _transMouse(e);
      List<double> last = _tempLines.get(_tempLines.count - 1, 1);
      _tempLines.set(_tempLines.count - 1, [last[0], last[1], loc[0].roundToDouble(), loc[1].roundToDouble()]);
      _points.add(new qt.Point(loc[0].round(), loc[1].round()));
      e.redraw = true;
      _mouseDown = false;
    }
  }
}
