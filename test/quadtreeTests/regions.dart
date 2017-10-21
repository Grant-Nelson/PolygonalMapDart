part of tests;

void addRegionTests(TestManager tests) {
  tests.add("Boundary Region Test", (TestArgs args) {
    qt.Boundary rect = new qt.Boundary(-2, -2, 2, 2);
    regionTest(args, rect, 0, 0, qt.BoundaryRegion.Inside);
    regionTest(args, rect, 2, 2, qt.BoundaryRegion.Inside);
    regionTest(args, rect, 2, -2, qt.BoundaryRegion.Inside);
    regionTest(args, rect, -2, 2, qt.BoundaryRegion.Inside);
    regionTest(args, rect, -2, -2, qt.BoundaryRegion.Inside);
    regionTest(args, rect, 0, 4, qt.BoundaryRegion.North);
    regionTest(args, rect, 4, 0, qt.BoundaryRegion.East);
    regionTest(args, rect, 0, -4, qt.BoundaryRegion.South);
    regionTest(args, rect, -4, 0, qt.BoundaryRegion.West);
    regionTest(args, rect, 4, 4, qt.BoundaryRegion.NorthEast);
    regionTest(args, rect, 4, -4, qt.BoundaryRegion.SouthEast);
    regionTest(args, rect, -4, 4, qt.BoundaryRegion.NorthWest);
    regionTest(args, rect, -4, -4, qt.BoundaryRegion.SouthWest);
  });
}

void regionTest(TestArgs args, qt.Boundary rect, int x, int y, int expRegion) {
  int result = rect.region(new qt.Point(x, y));
  if (result != expRegion) {
    args.error("Unexpected result from region:\n" +
        "   Boundary: $rect\n" +
        "   Point:    $x, $y\n" +
        "   Expected: ${qt.BoundaryRegion.getString(expRegion)}, $expRegion\n" +
        "   Result:   ${qt.BoundaryRegion.getString(result)}, $result\n");

    plotter.Plotter plot = new plotter.Plotter();
    plot.addRects([rect.xmin, rect.ymin, rect.width, rect.height])
      ..addColor(0.8, 0.0, 0.0)
      ..addPointSize(4.0);
    plot.addPoints([x, y])
      ..addColor(0.0, 0.8, 0.0)
      ..addPointSize(4.0);
    plot.updateBounds();
    plot.focusOnData();

    new plotSvg.PlotSvg.fromElem(args.addDiv(), plot);
  } else {
    args.info("Passed BoundaryRegion($rect, [$x, $y]) => ${qt.BoundaryRegion.getString(expRegion)}\n");
  }
}
