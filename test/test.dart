library tests;

import 'dart:html' as html;
import 'dart:async' as asy;
import 'dart:convert' as convert;

import 'package:PolygonalMapDart/Quadtree.dart' as qt;
import 'package:plotterDart/plotSvg.dart' as plotSvg;
import 'package:plotterDart/plotter.dart' as plotter;

part 'quadtreeTests/insertPoint.dart';
part 'quadtreeTests/regions.dart';

part 'tools/quadTreePlotter.dart';
part 'tools/quadTreeTester.dart';
part 'tools/shell.dart';
part 'tools/testArgs.dart';
part 'tools/testBlock.dart';
part 'tools/testManager.dart';

void main() {
  html.DivElement elem = new html.DivElement();
  TestManager tests = new TestManager(elem);

  addInsertPointTests(tests);
  addRegionTests(tests);

  shell(elem);
}
