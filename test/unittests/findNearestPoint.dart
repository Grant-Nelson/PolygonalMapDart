part of tests;

void addFindNearestPointTests(TestManager tests) {
  tests.add("Find Nearest Point Basic Test", (TestArgs args) {
    QuadTreeTester test = new QuadTreeTester(args);
    test.insertPoints([-3, -3, -3, 3, 3, 3, 3, -3]);

    test.checkFindNearestPoint(0, 0, 3, 3);
  });

  tests.add("Find Nearest Point Test", (TestArgs args) {
    QuadTreeTester test = new QuadTreeTester(args);
    test.insertPoints([
      1,
      5,
      5,
      1,
      3,
      3,
      2,
      6,
      8,
      8,
      4,
      1,
      10,
      10,
      0,
      10,
      10,
      0,
      0,
      0,
      0,
      1,
      0,
      2,
      1,
      0,
      2,
      0,
      10,
      1,
      10,
      8,
      7,
      10,
      4,
      10,
      10,
      12,
      20,
      21,
      12,
      2,
      1,
      12,
      13,
      5,
      -1,
      3,
      11,
      11,
      -1,
      -1
    ]);

    test.checkFindNearestPoint(0, 0, 0, 0);
    test.checkFindNearestPoint(10, 10, 10, 10);
    test.checkFindNearestPoint(2, 2, 3, 3);
    test.checkFindNearestPoint(0, 2, 0, 2);
    test.checkFindNearestPoint(14, 14, 11, 11);
    test.checkFindNearestPoint(42, 31, 20, 21);
    test.checkFindNearestPoint(-2, 8, 0, 10);
  });
}
