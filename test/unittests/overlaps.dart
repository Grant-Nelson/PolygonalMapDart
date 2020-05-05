part of tests;

void addOverlapsTests(TestManager tests) {
  tests.add("Overlaps Test", (TestArgs args) {
    qt.Boundary rectA = new qt.Boundary(8, 8, 15, 15);
    qt.Boundary rectB = new qt.Boundary(0, 8, 7, 15);
    qt.Boundary rectC = new qt.Boundary(8, 0, 15, 7);
    qt.Boundary rectD = new qt.Boundary(0, 0, 7, 7);
    qt.Edge edgeA = new qt.Edge(new qt.Point(-2, -4), new qt.Point(12, 14));

    overlapTest(args, rectA, edgeA, true);
    overlapTest(args, rectB, edgeA, true);
    overlapTest(args, rectC, edgeA, false);
    overlapTest(args, rectD, edgeA, true);

    qt.Boundary rectE = new qt.Boundary(-15, 32, 0, 47);
    qt.Edge edgeB = new qt.Edge(new qt.Point(4, 33), new qt.Point(-1, 52));
    overlapTest(args, rectE, edgeB, true);
  });
}

void overlapTest(TestArgs args, qt.IBoundary bounds, qt.IEdge edge, bool overlaps) {
  bool result = bounds.overlapsEdge(edge);
  if (result != overlaps) {
    args.error("Failed: Expected overlap ($overlaps) didn't match result:\n" +
        "   Bounds: $bounds\n" +
        "   Edge:   $edge\n\n");

    plotter.Plotter plot = new plotter.Plotter();
    plot.addRects([bounds.xmin.toDouble(), bounds.ymin.toDouble(), bounds.width.toDouble(), bounds.height.toDouble()])
      ..addColor(0.8, 0.0, 0.0)
      ..addPointSize(4.0);
    plot.addLines([edge.x1.toDouble(), edge.y1.toDouble(), edge.x2.toDouble(), edge.y2.toDouble()])
      ..addColor(0.0, 0.8, 0.0)
      ..addPointSize(4.0);
    plot.updateBounds();
    plot.focusOnData();
    plot.MouseHandles.add(new plotter.MouseCoords(plot));
    new plotSvg.PlotSvg.fromElem(args.addDiv(), plot);
  } else {
    args.info("Passed: $bounds.overlaps($edge) => $overlaps");
  }
}
