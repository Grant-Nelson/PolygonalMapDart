part of tests;

void addFirstLeftEdgeTests(TestManager tests) {
  tests.add("First Left Edge Basic Test", (TestArgs args) {
    QuadTreeTester test = new QuadTreeTester(args);
    test.insertPolygon([5, 5, 10, 5, 15, 5, 15, 15, 5, 15, 5, 10]);
    test.checkFirstLeftEdge(10, 10, 5, 10, 5, 5);
  });

  tests.add("First Left Edge Test", (TestArgs args) {
    QuadTreeTester test = new QuadTreeTester(args);
    test.insertPolygon([0, 0, 0, 10, 30, 10, 30, 30, 0, 30, 0, 40, 40, 40, 40, 0]);
    test.checkFirstLeftEdge(10, 5, 0, 0, 0, 10);
  });
}
