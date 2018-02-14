part of tests;

void addPolygonClipperTests(TestManager tests) {
  tests.add("Polygon Clipper 1 - No change", (TestArgs args) {
    _testClipper(args, "0, 5,  0, 0,  5, 0,  5, 5", ["0, 5,  0, 0,  5, 0,  5, 5"]);
  });

  tests.add("Polygon Clipper 2 - Change to CCW", (TestArgs args) {
    _testClipper(args, "0, 0,  0, 5,  5, 5,  5, 0", ["5, 5,  0, 5,  0, 0,  5, 0"]);
  });

  tests.add("Polygon Clipper 3 - Bowtie", (TestArgs args) {
    _testClipper(args, "0, 0, 0, 5, 5, 0, 5, 5",
        ["3, 3, 5, 0, 5, 5", "0, 5, 0, 0, 3, 3"]);
  });

  tests.add("Polygon Clipper 4 - Bowtie reversed", (TestArgs args) {
    _testClipper(args, "0, 5, 0, 0, 5, 5, 5, 0",
        ["0, 5, 0, 0, 3, 3", "5, 5, 3, 3, 5, 0"]);
  });

  tests.add("Polygon Clipper 5 - Big bowtie", (TestArgs args) {
    _testClipper(
        args, "-59, 81, -23, 32, -88, 38, -90, 75, -35, 69, -39, 24, -78, 84", [
      "-59, 81, -78, 84, -71, 73, -90, 75, -88, 38, -45, 34, -39, 24, -38, 33, -23, 32, -37, 50, -35, 69, -52, 71",
      "-52, 71, -71, 73, -45, 34, -38, 33, -37, 50"
    ]);
  });

  tests.add("Polygon Clipper 6 - Big bowtie reversed", (TestArgs args) {
    _testClipper(
        args, "-78, 84, -39, 24, -35, 69, -90, 75, -88, 38, -23, 32, -59, 81", [
      "-71, 73, -45, 34, -38, 33, -37, 50, -52, 71",
      "-78, 84, -71, 73, -90, 75, -88, 38, -45, 34, -39, 24, -38, 33, -23, 32, -37, 50, -35, 69, -52, 71, -59, 81"
    ]);
  });
}

void _testClipper(TestArgs args, String input, List<String> results,
    [bool plot = true]) {
  List<qt.Point> inputPnts = points.parse(input);
  List<List<qt.Point>> expPnts = new List<List<qt.Point>>();
  for (int i = 0; i < results.length; ++i) expPnts.add(points.parse(results[i]));

  List<List<qt.Point>> resultPnts = maps.PolygonClipper.Clip(inputPnts);

  if (expPnts.length != resultPnts.length) {
    args.error(
        "Lengths do not match: expected ${expPnts.length} but got ${resultPnts.length}:\n");
    args.info("input: ${points.format(inputPnts)}\n");
    for (int i = 0; i < max(expPnts.length, resultPnts.length); i++) {
      if (i < expPnts.length) args.info("exp $i: ${points.format(expPnts[i])}\n");
      if (i < resultPnts.length)
        args.info("got $i: ${points.format(resultPnts[i])}\n");
    }
    plot = true;
  } else {
    bool failed = false;
    for (int i = 0; i < expPnts.length; ++i) {
      if (!points.equals(expPnts[i], resultPnts[i])) {
        failed = true;
        break;
      }
    }

    if (failed) {
      plot = true;
      args.error("Some results did not match:\n");
      args.info("input: ${points.format(inputPnts)}\n");
      for (int i = 0; i < expPnts.length; ++i) {
        if (points.equals(expPnts[i], resultPnts[i])) {
          args.info("same $i: ${points.format(expPnts[i])}\n");
        } else {
          args.info("exp  $i: ${points.format(expPnts[i])}\n");
          args.info("got  $i: ${points.format(resultPnts[i])}\n");
        }
      }
    }
  }

  if (plot) {
    qtplotter.QuadTreePlotter plot = new qtplotter.QuadTreePlotter();
    plotter.Polygon inputPoly = plot.addGroup("Input").addPolygon([])
      ..addColor(0.0, 0.0, 0.0)
      ..addDirected(true);
    for (int i = 0; i < inputPnts.length; ++i) {
      inputPoly.add([inputPnts[i].x, inputPnts[i].y]);
    }

    for (int i = 0; i < resultPnts.length; ++i) {
      double f = i / resultPnts.length;
      plotter.Polygon poly = plot.addGroup("Result $i").addPolygon([])
        ..addColor(0.0, 1.0 - f, f)
        ..addDirected(true);
      List<qt.Point> pnts = resultPnts[i];
      for (int j = 0; j < pnts.length; ++j) {
        poly.add([pnts[j].x, pnts[j].y]);
      }
    }

    html.DivElement div = args.addDiv();
    plot.updateBounds();
    plot.focusOnData();
    new plotSvg.PlotSvg.fromElem(div, plot);
  }
}
