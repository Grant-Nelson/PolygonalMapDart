library quadtree_test;

import 'dart:io';

part 'InsertPoint.dart';
part 'TestArgs.dart';

//import 'package:PolygonalMap/Quadtree.dart' as qt;

/// The interface for unit-tests.
abstract class ITest {
  /// This is called to run the unit-test.=
  void run(TestArgs args);
}

void main() {}
