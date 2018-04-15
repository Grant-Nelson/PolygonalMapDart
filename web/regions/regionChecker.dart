part of main;

/// The colors to draw for different regions
List<plotter.Color> regionColors = [
  new plotter.Color(0.0, 0.0, 0.0),
  new plotter.Color(0.0, 0.0, 1.0),
  new plotter.Color(0.0, 1.0, 1.0),
  new plotter.Color(0.0, 1.0, 0.0),
  new plotter.Color(1.0, 1.0, 0.0),
  new plotter.Color(1.0, 0.0, 0.0),
  new plotter.Color(1.0, 0.0, 1.0),
];

/// A mouse handler for adding lines.
class RegionChecker implements plotter.IMouseHandle {
  qtPlot.QuadTreePlotter _plot;
  qtPlot.QuadTree _plotItem;
  maps.Regions _regions;
  bool _enabled;
  plotter.Lines _lines;
  plotter.ColorAttr _pointColor;
  plotter.Points _points;

  /// Creates a new mouse handler for adding lines.
  RegionChecker(this._regions, this._plot, this._plotItem) {
    _enabled = true;
    _lines = _plot.addLines([])..addColor(1.0, 0.5, 0.5);
    _pointColor = new plotter.ColorAttr.rgb(0.0, 0.0, 0.0);
    _points = _plot.addPoints([])..addPointSize(5.0)..addAttr(_pointColor);
  }

  /// Indicates of the point adder tool is enabled or not.
  bool get enabled => _enabled;
  set enabled(bool value) {
    _enabled = value;
    _points.clear();
    _lines.clear();
  }

  /// Translates the mouse location into the tree space based on the view.
  List<double> _transMouse(plotter.MouseEvent e) {
    plotter.Transformer trans = e.projection.mul(_plot.view);
    return [trans.untransformX(e.x), trans.untransformY(e.window.ymax - e.y)];
  }

  /// handles mouse down.
  void mouseDown(plotter.MouseEvent e) {
    if (_enabled) {
      List<double> loc = _transMouse(e);
      int x = loc[0].round();
      int y = loc[1].round();
      qt.Point pnt = new qt.Point(x, y);
      int region = _regions.getRegion(pnt);
      print("[$x, $y] -> $region");
    }
  }

  /// handles mouse moved.
  void mouseMove(plotter.MouseEvent e) {
    if (_enabled) {
      List<double> loc = _transMouse(e);
      int x = loc[0].round();
      int y = loc[1].round();
      qt.Point pnt = new qt.Point(x, y);

      _points.clear();
      int region = _regions.getRegion(pnt);
      _pointColor.color = regionColors[region];
      _points.add([x.toDouble(), y.toDouble()]);

      _lines.clear();
      qt.EdgeNode edge = _regions.tree.firstLeftEdge(pnt);
      if (edge != null) {
        _lines.add([edge.start.x, edge.start.y, edge.end.x, edge.end.y]);
        double x = (pnt.y - edge.start.y)*edge.dx/edge.dy + edge.start.x;
        _lines.add([pnt.x, pnt.y, x, pnt.y]);
      }

      e.redraw = true;
    }
  }

  /// handles mouse up.
  void mouseUp(plotter.MouseEvent e) {}
}
