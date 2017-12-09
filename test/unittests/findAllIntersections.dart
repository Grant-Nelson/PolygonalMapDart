part of tests;

void addFindAllIntersectionsTests(TestManager tests) {
  tests.add("Find All Intersections Test", (TestArgs args) {
    QuadTreeTester test = new QuadTreeTester(args);
    test.insertEdge(0, 0, 10, 0);
    test.insertEdge(10, 0, 10, 10);
    test.insertEdge(10, 10, 0, 10);
    test.insertEdge(0, 10, 0, 0);

    test.findAllIntersections(-2, -4, 12, 14, 2);
    test.findAllIntersections(-2, 4, 12, 14, 2);
    test.findAllIntersections(-2, 4, 5, 5, 1);
    test.findAllIntersections(5, 5, 12, 14, 1);
    test.findAllIntersections(3, 6, 6, 3, 0);
    test.findAllIntersections(0, 10, 10, 10, 3);
    test.findAllIntersections(3, 10, 6, 10, 1);
    test.findAllIntersections(-3, 10, 12, 10, 3);
    test.findAllIntersections(5, 5, 15, 5, 1);
  });

  tests.add("Find Intersections Incoming Lines Test", (TestArgs args) {
    QuadTreeTester test = new QuadTreeTester(args);
    test.insertEdge(50, 60, 100, 10);
    test.insertEdge(100, 10, 0, 10);
    test.insertEdge(0, 10, 50, 60);

    test.findFirstIntersection(90, 20, 90, 0, 100, 10, 0, 10);
  });
}
