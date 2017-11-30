part of tests;

void addRegionMapTests(TestManager tests) {
  tests.add("Region Map 1", (TestArgs args) {
    RegionMapTester test = new RegionMapTester(args);
    test.add([0, 0, 0, 10, 10, 10, 10, 0]);
    test.add([15, 5, 15, 15, 5, 15, 5, 5]);
    test.pointTest(0, 0, 0);
    test.pointTest(1, 1, 1);
    test.pointTest(4, 4, 1);
    test.pointTest(5, 5, 1);
    test.pointTest(6, 6, 2);
    test.pointTest(9, 9, 2);
    test.pointTest(10, 10, 2);
    test.pointTest(11, 11, 2);
    test.pointTest(14, 14, 2);
    test.pointTest(15, 15, 0);
    test.pointTest(16, 16, 0);
    test.pointTest(4, 11, 0);
    test.pointTest(6, 11, 2);
    test.pointTest(4, 9, 1);
    test.pointTest(6, 9, 2);
    test.pointTest(11, 4, 0);
    test.pointTest(11, 6, 2);
    test.pointTest(9, 4, 1);
    test.pointTest(9, 6, 2);
    test.showPlot();
  });

  tests.add("Region Map 2", (TestArgs args) {
    RegionMapTester test = new RegionMapTester(args);
    test.add([0, 3, 0, 7, 3, 10, 7, 10, 10, 7, 10, 3, 7, 0, 3, 0]);
    test.add([5, 8, 5, 12, 8, 15, 12, 15, 15, 12, 15, 8, 12, 5, 8, 5]);
    test.pointTest(4, 11, 0);
    test.pointTest(6, 11, 2);
    test.pointTest(4, 9, 1);
    test.pointTest(6, 9, 2);
    test.pointTest(11, 4, 0);
    test.pointTest(11, 6, 2);
    test.pointTest(9, 4, 1);
    test.pointTest(9, 6, 2);
    test.showPlot();
  });

  tests.add("Region Map 3", (TestArgs args) {
    RegionMapTester test = new RegionMapTester(args);
    test.add([0, 0, 0, 40, 10, 40, 10, 0]);
    test.add([0, 0, 0, 10, 30, 10, 30, 30, 0, 30, 0, 40, 40, 40, 40, 0]);
    test.pointTest(-2, 5, 0);
    test.pointTest(2, 5, 2);
    test.pointTest(8, 5, 2);
    test.pointTest(12, 5, 2);
    test.pointTest(28, 5, 2);
    test.pointTest(34, 5, 2);
    test.pointTest(42, 5, 0);

    test.pointTest(-2, 20, 0);
    test.pointTest(2, 20, 1);
    test.pointTest(8, 20, 1);
    test.pointTest(12, 20, 0);
    test.pointTest(28, 20, 0);
    test.pointTest(34, 20, 2);
    test.pointTest(42, 20, 0);

    test.pointTest(-2, 35, 0);
    test.pointTest(2, 35, 2);
    test.pointTest(8, 35, 2);
    test.pointTest(12, 35, 2);
    test.pointTest(28, 35, 2);
    test.pointTest(34, 35, 2);
    test.pointTest(42, 35, 0);
    test.showPlot();
  });

  tests.add("Region Map 4", (TestArgs args) {
    RegionMapTester test = new RegionMapTester(args);
    test.add([10, 0, 0, 0, 0, 4, 6, 5, 0, 6, 0, 10, 10, 10]);
    test.add([3, 0, 3, 10, 10, 10, 10, 0]);
    test.pointTest(4, 7, 2);
    test.pointTest(4, 5, 2);
    test.pointTest(4, 3, 2);
    test.pointTest(2, 7, 1);
    test.pointTest(2, 5, 0);
    test.pointTest(2, 3, 1);
    test.showPlot();
  });

  tests.add("Region Map 5", (TestArgs args) {
    RegionMapTester test = new RegionMapTester(args);
    test.add([0, 2, 0, 4, 4, 4, 4, 6, 0, 6, 0, 8, 10, 8, 10, 2]);
    test.add([2, 0, 2, 10, 8, 10, 8, 0]);
    test.pointTest(1, 1, 0);
    test.pointTest(1, 3, 1);
    test.pointTest(1, 5, 0);
    test.pointTest(1, 7, 1);
    test.pointTest(1, 9, 0);

    test.pointTest(3, 1, 2);
    test.pointTest(3, 3, 2);
    test.pointTest(3, 5, 2);
    test.pointTest(3, 7, 2);
    test.pointTest(3, 9, 2);

    test.pointTest(9, 1, 0);
    test.pointTest(9, 3, 1);
    test.pointTest(9, 5, 1);
    test.pointTest(9, 7, 1);
    test.pointTest(9, 9, 0);
    test.showPlot();
  });

  tests.add("Region Map 6", (TestArgs args) {
    RegionMapTester test = new RegionMapTester(args);
    test.add([3, 0, 3, 15, 12, 15, 12, 0]);
    test.add([0, 0, 3, 3, 3, 15, 12, 15, 12, 0]);
    test.pointTest(2, 1, 2);
    test.pointTest(3, 1, 2);
    test.pointTest(4, 1, 2);
    test.pointTest(1, 2, 0);
    test.showPlot();
  });

  tests.add("Region Map 7", (TestArgs args) {
    RegionMapTester test = new RegionMapTester(args);
    test.add([15, 5, 15, 15, 5, 15, 5, 5]);
    test.add([15, 5, 15, 15, 5, 15, 5, 5]);
    test.pointTest(10, 10, 2);
    test.showPlot();
  });

  tests.add("Region Map 8", (TestArgs args) {
    RegionMapTester test = new RegionMapTester(args);
    test.add([10, 5, 10, 10, 5, 10, 5, 5]);
    test.add([15, 0, 15, 15, 0, 15, 0, 0]);
    test.pointTest(-2, -2, 0);
    test.pointTest(2, 2, 2);
    test.pointTest(7, 7, 2);
    test.pointTest(12, 12, 2);
    test.pointTest(17, 17, 0);
    test.showPlot();
  });

  tests.add("Region Map 9", (TestArgs args) {
    RegionMapTester test = new RegionMapTester(args);
    test.add([15, 0, 15, 15, 0, 15, 0, 0]);
    test.add([10, 5, 10, 10, 5, 10, 5, 5]);
    test.pointTest(-2, 2, 0);
    test.pointTest(2, 2, 1);
    test.pointTest(6, 2, 1);
    test.pointTest(9, 2, 1);
    test.pointTest(12, 2, 1);
    test.pointTest(16, 2, 0);

    test.pointTest(-2, 8, 0);
    test.pointTest(2, 8, 1);
    test.pointTest(6, 8, 2);
    test.pointTest(9, 8, 2);
    test.pointTest(12, 8, 1);
    test.pointTest(16, 8, 0);
    test.showPlot();
  });
}

class RegionMapTester {
  TestArgs _args;

  maps.Regions _map;

  List<List<int>> _polygons;

  Map<int, List<int>> _points;

  Map<int, List<int>> _errPnts;

  List<List<double>> _colors;

  RegionMapTester(this._args) {
    _map = new maps.Regions();
    _polygons = new List<List<int>>();
    _points = new Map<int, List<int>>();
    _errPnts = new Map<int, List<int>>();
    _colors = new List<List<double>>();
    _addColor(0.0, 0.0, 0.0);
    _addColor(1.0, 0.0, 0.0);
    _addColor(0.0, 1.0, 0.0);
    _addColor(0.0, 0.0, 1.0);
    _addColor(0.6, 0.6, 0.0);
    _addColor(0.6, 0.0, 0.6);
    _addColor(0.0, 0.6, 0.6);
  }

  void _addColor(double red, double green, double blue) {
    _colors.add([red, green, blue]);
  }

  void add(List<int> polygon) {
    _polygons.add(polygon);
    _map.addRegionWithCoords(_polygons.length, polygon);
    if (!_map.tree.validate()) _args.fail();
  }

  void _addPoint(Map<int, List<int>> points, int x, int y, int value) {
    List<int> pnts = points[value];
    if (pnts == null) {
      pnts = new List<int>();
    }
    pnts.add(x);
    pnts.add(y);
    points[value] = pnts;
  }

  void pointTest(int x, int y, int exp) {
    _addPoint(_points, x, y, exp);
    int result = _map.getRegion(new qt.Point(x, y));
    if (exp != result) {
      _addPoint(_errPnts, x, y, result);
      _args.error("Expected $exp but got $result from $x, $y.\n");
    }
  }

  plotSvg.PlotSvg showPlot() {
    qtplotter.QuadTreePlotter plot = new qtplotter.QuadTreePlotter();
    plotter.Group treeGrp = plot.addGroup("Tree");
    plot.addTree(treeGrp, _map.tree);
    int count = _polygons.length;

    plotter.Group initPolys = plot.addGroup("Initial Polygons");
    for (int i = 0; i < count; i++) {
      List<int> poly = _polygons[i];
      if (poly != null) {
        List<double> clr = _colors[i + 1];
        plotter.Polygon polyItem = initPolys.addGroup("Polygon #$i").addPolygon([])
          ..addColor(clr[0], clr[1], clr[2])
          ..addDirected(true);
        for (int j = 0; j < poly.length - 1; j += 2) {
          polyItem.add([poly[j].toDouble(), poly[j + 1].toDouble()]);
        }
      }
    }

    plotter.Group finalPolys = plot.addGroup("Final Polygons");
    List<plotter.Lines> lines = new List<plotter.Lines>(count + 1);
    for (int i = 0; i <= count; i++) {
      List<double> clr = _colors[i];
      lines[i] = finalPolys.addGroup("#$i Edges").addLines([])
        ..addColor(clr[0], clr[1], clr[2])
        ..addDirected(true);
    }

    _map.tree.foreachEdge(new _LineCollector(lines));

    plotter.Group errPntGroup = plot.addGroup("Error Points");
    for (int i = 0; i <= count; i++) {
      List<int> points = _errPnts[i];
      if (points != null) {
        List<double> clr = _colors[i];
        plotter.Points pnts = errPntGroup.addPoints([])
          ..addColor(clr[0], clr[1], clr[2])
          ..addPointSize(6.0);
        for (int j = 0; j < points.length; j += 2) {
          pnts.add([points[j].toDouble(), points[j + 1].toDouble()]);
        }
      }
    }

    plotter.Group testPnts = plot.addGroup("Test Points");
    for (int i = 0; i <= count; i++) {
      List<int> points = _points[i];
      if (points != null) {
        List<double> clr = _colors[i];
        plotter.Points pnts = testPnts.addPoints([])
          ..addColor(clr[0], clr[1], clr[2])
          ..addPointSize(3.0);
        for (int j = 0; j < points.length; j += 2) {
          pnts.add([points[j].toDouble(), points[j + 1].toDouble()]);
        }
      }
    }

    html.DivElement div = _args.addDiv();
    plot.updateBounds();
    plot.focusOnData();
    return new plotSvg.PlotSvg.fromElem(div, plot);
  }
}

class _LineCollector implements qt.IEdgeHandler {
  List<plotter.Lines> _lines;

  _LineCollector(this._lines);

  bool handle(qt.EdgeNode edge) {
    maps.EdgeSide pair = edge.data;
    double dx = edge.dx.toDouble();
    double dy = edge.dy.toDouble();
    double length = sqrt(dx * dx + dy * dy);
    if (length > 1.0e-12) {
      double height = 0.1;
      dx = dx * height / length;
      dy = dy * height / length;
      _lines[pair.left].add([edge.x1 - dy, edge.y1 + dx, edge.x2 - dy, edge.y2 + dx]);
      _lines[pair.right].add([edge.x1 + dy, edge.y1 - dx, edge.x2 + dy, edge.y2 - dx]);
    }
    return true;
  }
}
