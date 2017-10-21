part of tests;

class QuadTreeTester {
  TestArgs _args;

  qt.QuadTree _tree;

  QuadTreeTester(this._args) {
    _tree = new qt.QuadTree();
  }

  TestArgs get args => _args;

  qt.QuadTree get tree => _tree;

  void showPlotOnFail() {
    if (_args.failed) showPlot();
  }

  void showPlot() {
    QuadTreePlotter.Show(_tree, _args.addDiv());
  }

  plotSvg.PlotSvg _showPlot(plotter.Plotter plot) {
    return new plotSvg.PlotSvg.fromElem(_args.addDiv(), plot);
  }

  qt.PointNode insertPoint(int x, int y) {
    qt.Point pnt = new qt.Point(x, y);
    int oldCount = _tree.pointCount;
    qt.PointNode oldPoint = _tree.findPoint(pnt);
    qt.PointNode point = _tree.insertPoint(pnt);
    int newCount = _tree.pointCount;
    qt.PointNode newPoint = _tree.findPoint(pnt);

    if (oldPoint == null) {
      if (oldCount + 1 != newCount) {
        _args.error("The old count should be one less than the new count after insertPoint($x, $y):" +
            "\n   Old Count: $oldCount" +
            "\n   New Count: $newCount");
      }
    } else {
      if (oldCount != newCount) {
        _args.error("The old count should be the same as the new count after insertPoint($x, $y):" +
            "\n   Old Count: $oldCount" +
            "\n   New Count: $newCount");
      }
      if (oldPoint != point) {
        _args.error("The pre-insert found point does not equal the inserted point after insertPoint($x, $y):" +
            "\n   Found Point:    $oldPoint" +
            "\n   Inserted Point: $point");
      }
    }
    if (point != newPoint) {
      _args.error("The post-insert found point does not equal the inserted point after insertPoint($x, $y):" +
          "\n   Found Point:    $newPoint" +
          "\n   Inserted Point: $point");
    }
    StringBuffer sout = new StringBuffer();
    if (!_tree.validate(sout, null)) {
      _args.error("Failed validation after insertPoint($x, $y):" + "\n${sout.toString()}");
    }

    return point;
  }

  void insertPoints(List<int> pntCoords) {
    int count = pntCoords.length ~/ 2;
    for (int i = 0; i < count; ++i) {
      _tree.insertPoint(new qt.Point(pntCoords[i * 2], pntCoords[i * 2 + 1]));
    }
  }

  void insertEdge(int x1, int y1, int x2, int y2) {
    //quadtree.EdgeNode edge =
    _tree.insertEdge(new qt.Edge(new qt.Point(x1, y1), new qt.Point(x2, y2)));

    // TODO: Add to test.

    StringBuffer sout = new StringBuffer();
    if (!_tree.validate(sout, null)) {
      _args.error("Failed validation after insertEdge($x1, $y1, $x2, $y2):\n${sout.toString()}");
    }
  }

  void insertPolygon(List<int> pntCoords) {
    qt.PointNodeVector nodes = new qt.PointNodeVector();
    int count = pntCoords.length ~/ 2;
    for (int i = 0; i < count; ++i) {
      qt.PointNode node = _tree.insertPoint(new qt.Point(pntCoords[i * 2], pntCoords[i * 2 + 1]));
      nodes.nodes.add(node);
    }
    for (int i = 0; i < count; ++i) {
      _tree.insertEdge(nodes.edge(i));
    }
  }

  void checkFirstLeftEdge(int x, int y, int x1, int y1, int x2, int y2) {
    qt.EdgeNode node = _tree.firstLeftEdge(new qt.Point(x, y));
    bool showPlot = false;
    if (node == null) {
      _args.error("Found to find first edge.");
      showPlot = true;
    } else if ((node.x1 != x1) || (node.y1 != y1) || (node.x2 != x2) || (node.y2 != y2)) {
      _args.error("First edge found didn't match expected:" +
          "\n   Gotten:   ${node.edge}" +
          "\n   Expected: [$x1, $y1, $x2, $y2]");
      showPlot = true;
    }

    if (showPlot) {
      QuadTreePlotter plot = new QuadTreePlotter();
      plot.addTree(plot.addGroup("Tree"), _tree);
      if (node != null) {
        plot.addLines([node.x1, node.y1, node.x2, node.y2]).addColor(0.2, 0.2, 1.0);
      }
      plot.addPoints([x, y])
        ..addColor(1.0, 0.0, 0.0)
        ..addPointSize(3.0);
      _showPlot(plot);
    }
  }

  void findAllIntersections(int x1, int y1, int x2, int y2, int count) {
    qt.Edge edge = new qt.Edge(new qt.Point(x1, y1), new qt.Point(x2, y2));
    qt.IntersectionSet inters = new qt.IntersectionSet();
    _tree.findAllIntersections(edge, null, inters);
    bool showPlot = false;

    StringBuffer sout = new StringBuffer();
    if (!_tree.validate(sout, null)) {
      _args.info(sout.toString());
      _args.info(_tree.toString());
      _args.fail();
      showPlot = true;
    }

    if (inters.results.length != count) {
      _args.info("Expected to find $count intersections but found ${inters.results.length}.\n");
      _args.info("${inters.toString()}\n");
      _args.info("${_tree.toString()}\n");
      _args.fail();
      showPlot = true;
    }

    qt.IntersectionResult firstInt = _tree.findFirstIntersection(edge, null);
    if (firstInt != null) {
      if (count < 1) {
        _args.info("Expected to find no intersections but found a first intersection.\n");
        _args.info("${firstInt.toString()}\n");
        _args.info("${_tree.toString()}\n");
        _args.fail();
        showPlot = true;
      }
    } else {
      if (count > 0) {
        _args.info("Expected to find $count intersections but found no first intersection.\n");
        _args.info("${_tree.toString()}\n");
        _args.fail();
        showPlot = true;
      }
    }

    if (showPlot) {
      QuadTreePlotter plot = new QuadTreePlotter();
      plotter.Group group = plot.addGroup("Intersects: $edge => $count");
      plot.addTree(group, _tree);

      plotter.Lines lines = new plotter.Lines();
      lines.add([edge.x1, edge.y1, edge.x2, edge.y2]);
      lines.addColor(0.0, 0.0, 0.8);
      plot.add([lines]);

      plotter.Points points = new plotter.Points();
      for (qt.IntersectionResult inter in inters.results) {
        if (inter.point != null) {
          points.add([inter.point.x, inter.point.y]);
        }
      }
      points.addPointSize(4.0);
      points.addColor(1.0, 0.0, 0.0);
      plot.add([points]);

      plot.updateBounds();
      plot.focusOnData();
      _showPlot(plot);
    }
  }

  void checkForeach(List<int> inside, List<int> outside, int x1, int y1, int x2, int y2) {
    Set<qt.PointNode> expOutside = new Set<qt.PointNode>();
    for (int i = 0; i < outside.length; i += 2) expOutside.add(insertPoint(outside[i], outside[i + 1]));

    Set<qt.PointNode> expInside = new Set<qt.PointNode>();
    for (int i = 0; i < inside.length; i += 2) expInside.add(insertPoint(inside[i], inside[i + 1]));

    qt.Boundary boundary = new qt.Boundary(x1, y1, x2, y2);
    qt.PointCollectorHandle collector = new qt.PointCollectorHandle();
    _tree.foreachPoint(collector, boundary);
    Set<qt.PointNode> foundPoints = collector.collection;

    Set<qt.PointNode> wrongOutside = new Set<qt.PointNode>();
    for (qt.PointNode point in expInside) {
      if (!foundPoints.remove(point)) {
        wrongOutside.add(point);
      }
    }
    Set<qt.PointNode> wrongInside = new Set<qt.PointNode>();
    wrongInside.addAll(foundPoints);

    bool showPlot = false;
    if ((wrongOutside.length > 0) || (wrongInside.length > 0)) {
      _args.error("Foreach point failed to return expected results:" +
          "\n   Expected Outside: $expOutside" +
          "\n   Expected Inside:  $expInside" +
          "\n   Wrong Outside:    $wrongOutside" +
          "\n   Wrong Inside:     $wrongInside");
      showPlot = true;
    }

    if (showPlot) {
      QuadTreePlotter plot = new QuadTreePlotter();

      plotter.Group group = plot.addGroup("Tree");
      plot.addTree(group, _tree);
      plotter.Points expOutsidePoint = plot.addGroup("Expected Outside").addPoints([]);
      expOutsidePoint.addColor(0.0, 0.0, 1.0);
      expOutsidePoint.addPointSize(4.0);
      plot.addPoints([expOutsidePoint, expOutside]);

      plotter.Points expInsidePoint = plot.addGroup("Expected Inside").addPoints([]);
      expInsidePoint.addColor(0.0, 1.0, 0.0);
      expInsidePoint.addPointSize(4.0);
      plot.addPoints([expInsidePoint, expInside]);

      plotter.Points wrongOutsidePoint = plot.addGroup("Wrong Outside").addPoints([]);
      wrongOutsidePoint.addColor(1.0, 0.0, 0.0);
      wrongOutsidePoint.addPointSize(4.0);
      plot.addPoints([wrongOutsidePoint, wrongOutside]);

      plotter.Points wrongInsidePoint = plot.addGroup("Wrong Inside").addPoints([]);
      wrongInsidePoint.addColor(1.0, 0.5, 0.0);
      wrongInsidePoint.addPointSize(4.0);
      plot.addPoints([wrongInsidePoint, wrongInside]);

      plot.addGroup("Boundary").addRects([x1, y1, x2 - x1, y2 - y1]);
      _showPlot(plot);
    }
  }

  void checkFindNearestPoint(int x, int y, int expX, int expY) {
    qt.Point focus = new qt.Point(x, y);
    qt.Point exp = new qt.Point(expX, expY);
    qt.PointNode result = _tree.findNearestPointToPoint(focus);

    bool showPlot = false;
    if (!qt.Point.equals(exp, result)) {
      _args.error("Foreach point failed to return expected results:" +
          "\n   Focus:     ${focus.toString()}" +
          "\n   Exp:       ${exp.toString()}" +
          "\n   Exp Dist2: ${qt.Point.distance2(exp, focus)}" +
          "\n   Result:    ${result.toString()}");
      showPlot = true;
    }

    TestHandle hndl = new TestHandle();
    _tree.foreachPoint(hndl);

    if (!qt.Point.equals(hndl.found, result)) {
      _args.error("FindNearestPoint didn't find nearest point:" +
          "\n   Focus:        ${focus.toString()}" +
          "\n   Result:       ${result.toString()}" +
          "\n   Result Dist2: ${qt.Point.distance2(focus, result)}" +
          "\n   Found:        ${hndl.found.toString()}" +
          "\n   Found Dist2:  ${hndl.minDist2}");
      showPlot = true;
    }

    if (showPlot) {
      QuadTreePlotter plot = new QuadTreePlotter();
      plotter.Group group = plot.addGroup("Tree");

      plot.addTree(group, _tree);
      plotter.Points focusPnt = plot.addGroup("Focus").addPoints([]);
      focusPnt.addColor(0.0, 0.0, 1.0);
      focusPnt.addPointSize(4.0);
      plot.addPoint(focusPnt, focus);

      plotter.Points resultPnt = plot.addGroup("Result").addPoints([]);
      resultPnt.addColor(0.0, 1.0, 0.0);
      resultPnt.addPointSize(4.0);
      plot.addPoint(resultPnt, result);

      plotter.Points foundPnt = plot.addGroup("Found").addPoints([]);
      foundPnt.addColor(1.0, 0.0, 0.0);
      foundPnt.addPointSize(4.0);
      plot.addPoint(foundPnt, hndl.found);

      _showPlot(plot);
    }
  }
}

class TestHandle implements qt.IPointHandler {
  double minDist2 = double.MAX_FINITE;
  qt.PointNode found = null;
  bool handle(qt.PointNode point) {
    double dist2 = qt.Point.distance2(found, point);
    if (dist2 < minDist2) {
      minDist2 = dist2;
      found = point;
    }
    return true;
  }
}
