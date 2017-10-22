part of tests;

void addConversionsTests(TestManager tests) {
  tests.add("Conversions Test", (TestArgs args) {
    qt.Coordinates coords = new qt.Coordinates(
        230.0, 15000.0, 0.0001, 0.01, new NumberFormat("#0.0000", "en_US"), new NumberFormat("#0.00", "en_US"));
    qt.QuadTree tree = new qt.QuadTree();

    qt.IPoint pnt = tree.insertPoint(coords.toPoint(3.5555555555555, 3.55555555555));
    String result = coords.toPointString(pnt);
    String exp = "[3.5556, 3.56]";
    if (result != exp) {
      args.error("Failed: Coordinates expected to be " + exp + " but got " + result + ".\n\n");
    } else {
      args.info("Passed: $result\n");
    }
  });
}
