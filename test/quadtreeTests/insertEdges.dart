part of tests;

void addInsertEdgesTests(TestManager tests) {
  tests.add("Insert Edges Basic Test", (TestArgs args) {
    QuadTreeTester test = new QuadTreeTester(args);
    test.insertPoint(0, 1);
    test.insertPoint(1, 2);
    test.insertPoint(2, 3);
    test.insertPoint(8, 3);
    test.insertPoint(9, 2);
    test.insertPoint(10, 1);
    test.insertEdge(0, 1, 10, 1);
    test.insertEdge(1, 2, 9, 2);
    test.insertEdge(2, 3, 8, 3);
    test.showPlot();
  });

  tests.add("Insert Edges Test", (TestArgs args) {
    QuadTreeTester test = new QuadTreeTester(args);
    test.insertEdge(0, 0, 0, 10);
    test.insertEdge(0, 10, 10, 10);
    test.insertEdge(10, 10, 10, 0);
    test.insertEdge(10, 0, 0, 0);
    test.insertEdge(5, 5, 5, 15);
    test.insertEdge(5, 15, 15, 15);
    test.insertEdge(15, 15, 15, 5);
    test.insertEdge(15, 5, 5, 5);
    test.insertEdge(0, 0, 5, 5);
    test.insertEdge(0, 10, 5, 15);
    test.insertEdge(10, 10, 15, 15);
    test.insertEdge(10, 0, 15, 5);
    test.showPlot();
  });
}
