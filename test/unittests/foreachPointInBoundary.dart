part of tests;

void addForeachPointInBoundaryTests(TestManager tests) {
  tests.add("Foreach Point In Boundary Test 1", (TestArgs args) {
    QuadTreeTester test = new QuadTreeTester(args);
    List<int> inside = [
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
    ];
    List<int> outside = [
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
      -1,
    ];
    test.checkForeach(inside, outside, 0, 0, 10, 10);
  });

  tests.add("Foreach Point In Boundary Test 2", (TestArgs args) {
    QuadTreeTester test = new QuadTreeTester(args);
    List<int> inside = [
      3,
      3,
    ];
    List<int> outside = [
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
      -1,
      1,
      5,
      5,
      1,
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
      2,
      6,
    ];
    test.checkForeach(inside, outside, 3, 2, 5, 6);
  });

  tests.add("Foreach Point In Boundary Test 3", (TestArgs args) {
    QuadTreeTester test = new QuadTreeTester(args);
    List<int> inside = [3, 3, 5, 5];
    List<int> outside = [
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
      -1,
      1,
      5,
      5,
      1,
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
      2,
      6,
      40,
      40,
      40,
      2,
      2,
      46,
    ];
    test.checkForeach(inside, outside, 2, 3, 6, 5);
  });

  tests.add("Foreach Point In Boundary Test 4", (TestArgs args) {
    QuadTreeTester test = new QuadTreeTester(args);
    List<int> inside = [
      15,
      15,
    ];
    List<int> outside = [
      0,
      0,
      30,
      30,
    ];
    test.checkForeach(inside, outside, 10, 10, 20, 20);
  });

  tests.add("Foreach Point In Boundary Test 5", (TestArgs args) {
    QuadTreeTester test = new QuadTreeTester(args);
    List<int> inside = [
      15,
      15,
    ];
    List<int> outside = [];
    test.checkForeach(inside, outside, 10, 10, 20, 20);
  });
}
