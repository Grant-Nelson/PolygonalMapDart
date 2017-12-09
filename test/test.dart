library tests;

import 'dart:html' as html;
import 'dart:async' as asy;
import 'dart:math';

import 'package:intl/intl.dart';

import 'package:plotterDart/plotSvg.dart' as plotSvg;
import 'package:plotterDart/plotter.dart' as plotter;

import 'package:PolygonalMapDart/Quadtree.dart' as qt;
import 'package:PolygonalMapDart/Maps.dart' as maps;
import 'package:PolygonalMapDart/Plotter.dart' as qtplotter;

part 'tools/quadTreeTester.dart';
part 'tools/testArgs.dart';
part 'tools/testBlock.dart';
part 'tools/testManager.dart';

part 'unittests/conversions.dart';
part 'unittests/edgeIntersect.dart';
part 'unittests/findAllIntersections.dart';
part 'unittests/findNearestPoint.dart';
part 'unittests/firstLeftEdge.dart';
part 'unittests/foreachPointInBoundary.dart';
part 'unittests/insertEdges.dart';
part 'unittests/insertPoint.dart';
part 'unittests/overlaps.dart';
part 'unittests/regionMap.dart';
part 'unittests/regions.dart';

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
  addRegionMapTests(tests);
  addRegionTests(tests);

  html.DivElement scrollPage = new html.DivElement();
  scrollPage.className = "scroll_page";

  html.DivElement pageCenter = new html.DivElement();
  pageCenter.className = "page_center";
  scrollPage.append(pageCenter);

  if (elem != null) {
    html.DivElement elemContainer = new html.DivElement();
    pageCenter.append(elemContainer);
    elemContainer.append(elem);

    html.DivElement endPage = new html.DivElement();
    endPage.className = "end_page";
    elemContainer.append(endPage);
  }

  html.document.title = "Unit-tests";
  html.BodyElement body = html.document.body;
  body.append(scrollPage);
}
