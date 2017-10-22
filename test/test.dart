library tests;

import 'dart:html' as html;
import 'dart:async' as asy;

import 'package:intl/intl.dart';

import 'package:PolygonalMapDart/Quadtree.dart' as qt;
import 'package:plotterDart/plotSvg.dart' as plotSvg;
import 'package:plotterDart/plotter.dart' as plotter;

part 'tools/quadTreePlotter.dart';
part 'tools/quadTreeTester.dart';
part 'tools/shell.dart';
part 'tools/testArgs.dart';
part 'tools/testBlock.dart';
part 'tools/testManager.dart';

part 'quadtreeTests/conversions.dart';
part 'quadtreeTests/edgeIntersect.dart';
part 'quadtreeTests/findAllIntersections.dart';
part 'quadtreeTests/findNearestPoint.dart';
part 'quadtreeTests/firstLeftEdge.dart';
part 'quadtreeTests/foreachPointInBoundary.dart';
part 'quadtreeTests/insertEdges.dart';
part 'quadtreeTests/insertPoint.dart';
part 'quadtreeTests/overlaps.dart';
part 'quadtreeTests/regions.dart';

void main() {
  html.DivElement elem = new html.DivElement();
  TestManager tests = new TestManager(elem);

  addConversionsTests(tests);
  addEdgeIntersectTests(tests);
  addFindAllIntersectionsTests(tests);
  addFindNearestPointTests(tests);
  addFirstLeftEdgeTests(tests);
  addForeachPointInBoundaryTests(tests);
  addInsertEdgesTests(tests);
  addInsertPointTests(tests);
  addOverlapsTests(tests);
  addRegionTests(tests);

  shell(elem);
}
