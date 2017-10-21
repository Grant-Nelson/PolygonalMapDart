part of tests;

void addInsertPointTests(TestManager tests) {
  tests.add("Basic Point Insertion", (TestArgs args) {
    QuadTreeTester test = new QuadTreeTester(args);
    test.insertPoint(0, 0);
    test.insertPoint(0, 10);
    test.insertPoint(10, 10);
    test.insertPoint(10, 0);
    test.insertPoint(5, 5);
    test.insertPoint(5, 15);
    test.insertPoint(15, 15);
    test.insertPoint(15, 5);
    test.showPlot();
  });

  tests.add("Another Point Insertion", (TestArgs args) {
    QuadTreeTester test = new QuadTreeTester(args);
    test.insertPoint(0, -1);
    test.insertPoint(0, 1);
    test.insertPoint(10, -1);
    test.insertPoint(10, 1);
    test.showPlot();
  });
}
