part of tests;

void addEdgeIntersectTests(TestManager tests) {
  tests.add("Edge Intersect Test", (TestArgs args) {
    edgeIntersectTest(args, e(0, 0, 1, 1), e(0, 0, 1, 1), "Hit Same null None None");
    edgeIntersectTest(args, e(0, 0, 1, 1), e(1, 1, 0, 0), "Hit Opposite null None None");

    edgeIntersectTest(args, e(0, 0, 1, 1), e(1, 1, 2, 2), "Hit Collinear [1, 1] AtEnd AtStart");
    edgeIntersectTest(args, e(0, 0, 1, 1), e(2, 2, 1, 1), "Hit Collinear [1, 1] AtEnd AtEnd");
    edgeIntersectTest(args, e(1, 1, 0, 0), e(1, 1, 2, 2), "Hit Collinear [1, 1] AtStart AtStart");
    edgeIntersectTest(args, e(1, 1, 0, 0), e(2, 2, 1, 1), "Hit Collinear [1, 1] AtStart AtEnd");

    edgeIntersectTest(args, e(0, 0, 1, 0), e(1, 0, 2, 0), "Hit Collinear [1, 0] AtEnd AtStart");
    edgeIntersectTest(args, e(0, 0, 1, 0), e(2, 0, 1, 0), "Hit Collinear [1, 0] AtEnd AtEnd");
    edgeIntersectTest(args, e(1, 0, 0, 0), e(1, 0, 2, 0), "Hit Collinear [1, 0] AtStart AtStart");
    edgeIntersectTest(args, e(1, 0, 0, 0), e(2, 0, 1, 0), "Hit Collinear [1, 0] AtStart AtEnd");

    edgeIntersectTest(args, e(0, 0, 1, 0), e(2, 0, 3, 0), "Miss Collinear null None None");
    edgeIntersectTest(args, e(0, 0, 1, 0), e(3, 0, 2, 0), "Miss Collinear null None None");
    edgeIntersectTest(args, e(1, 0, 0, 0), e(2, 0, 3, 0), "Miss Collinear null None None");
    edgeIntersectTest(args, e(1, 0, 0, 0), e(3, 0, 2, 0), "Miss Collinear null None None");

    edgeIntersectTest(args, e(0, 0, 1, 1), e(2, 2, 3, 3), "Miss Collinear null None None");
    edgeIntersectTest(args, e(0, 0, 1, 1), e(3, 3, 2, 2), "Miss Collinear null None None");
    edgeIntersectTest(args, e(1, 1, 0, 0), e(2, 2, 3, 3), "Miss Collinear null None None");
    edgeIntersectTest(args, e(1, 1, 0, 0), e(3, 3, 2, 2), "Miss Collinear null None None");

    edgeIntersectTest(args, e(0, 0, 1, 1), e(1, 1, 0, 2), "Hit Point [1, 1] AtEnd AtStart");
    edgeIntersectTest(args, e(0, 0, 1, 1), e(0, 2, 1, 1), "Hit Point [1, 1] AtEnd AtEnd");
    edgeIntersectTest(args, e(1, 1, 0, 0), e(1, 1, 0, 2), "Hit Point [1, 1] AtStart AtStart");
    edgeIntersectTest(args, e(1, 1, 0, 0), e(0, 2, 1, 1), "Hit Point [1, 1] AtStart AtEnd");

    edgeIntersectTest(args, e(0, 2, 4, 2), e(2, 0, 2, 4), "Hit Point [2, 2] InMiddle InMiddle");
    edgeIntersectTest(args, e(0, 2, 4, 2), e(2, 0, 2, 2), "Hit Point [2, 2] InMiddle AtEnd");
    edgeIntersectTest(args, e(0, 2, 4, 2), e(2, 2, 2, 4), "Hit Point [2, 2] InMiddle AtStart");
    edgeIntersectTest(args, e(0, 2, 2, 2), e(2, 0, 2, 4), "Hit Point [2, 2] AtEnd InMiddle");
    edgeIntersectTest(args, e(2, 2, 4, 2), e(2, 0, 2, 4), "Hit Point [2, 2] AtStart InMiddle");
  });
}

qt.Edge e(int x1, int y1, int x2, int y2) {
  return new qt.Edge(new qt.Point(x1, y1), new qt.Point(x2, y2));
}

void edgeIntersectTest(TestArgs args, qt.Edge edgeA, qt.Edge edgeB, String exp) {
  qt.IntersectionResult result = qt.Edge.intersect(edgeA, edgeB);

  String type = "${result.type}".substring("IntersectionType.".length);
  String locA = "${result.locA}".substring("IntersectionLocation.".length);
  String locB = "${result.locB}".substring("IntersectionLocation.".length);

  String resultStr = (result.intersects ? "Hit" : "Miss") + " " + "$type ${result.point} $locA $locB";
  if (exp != resultStr) {
    if (!args.failed) {
      plotter.Plotter plot = new plotter.Plotter();
      plot.addLines([edgeA.x1, edgeA.y1, edgeA.x2, edgeA.y2, edgeB.x1, edgeB.y1, edgeB.x2, edgeB.y2]);
      plot.updateBounds();
      plot.focusOnData();
      new plotSvg.PlotSvg.fromElem(args.addDiv(), plot);
    }

    args.error("Failed: Unexpected result from edge interscetion:\n" +
        "   Edge A:   $edgeA\n" +
        "   Edge B:   $edgeB\n" +
        "   Full:     ${result.toString("\n                 ")}\n" +
        "   Result:   $resultStr\n" +
        "   Expected: $exp\n\n");
  } else {
    args.info("Passed: $resultStr\n");
  }
}
