library main;

import 'dart:html' as html;
import 'package:plotterDart/plotSvg.dart' as plotSvg;
import 'package:plotterDart/plotter.dart' as plotter;
import 'package:PolygonalMapDart/Plotter.dart' as qtPlot;
import 'package:PolygonalMapDart/Quadtree.dart' as qt;
import 'package:PolygonalMapDart/Maps.dart' as maps;

part 'boolValue.dart';
part 'driver.dart';
part 'polygonAdder.dart';
part 'regionChecker.dart';

void main() {
  html.document.title = "Points & Lines";
  html.BodyElement body = html.document.body;

  html.DivElement menu = new html.DivElement();
  menu.className = "menu";
  body.append(menu);

  html.DivElement plotElem = new html.DivElement();
  plotElem.className = "plot_target";
  body.append(plotElem);

  qtPlot.QuadTreePlotter plot = new qtPlot.QuadTreePlotter();
  plotSvg.PlotSvg svgPlot = new plotSvg.PlotSvg.fromElem(plotElem, plot);
  Driver dvr = new Driver(svgPlot, plot);

  addMenuView(menu, dvr);
  addMenuTools(menu, dvr);
}

void addMenuView(html.DivElement menu, Driver dvr) {
  html.DivElement dropDown = new html.DivElement()..className = "dropdown";
  menu.append(dropDown);

  html.DivElement text = new html.DivElement()..text = "View";
  dropDown.append(text);

  html.DivElement items = new html.DivElement()..className = "dropdown-content";
  dropDown.append(items);

  addMenuItem(items, "Center View", dvr.centerView);
  addMenuItem(items, "Points", dvr.points);
  addMenuItem(items, "Lines", dvr.lines);
  addMenuItem(items, "Empty Nodes", dvr.emptyNodes);
  addMenuItem(items, "Branch Nodes", dvr.branchNodes);
  addMenuItem(items, "Pass Nodes", dvr.passNodes);
  addMenuItem(items, "Point Nodes", dvr.pointNodes);
  addMenuItem(items, "Boundary", dvr.boundary);
  addMenuItem(items, "Root Boundary", dvr.rootBoundary);
}

void addMenuTools(html.DivElement menu, Driver dvr) {
  html.DivElement dropDown = new html.DivElement()..className = "dropdown";
  menu.append(dropDown);

  html.DivElement text = new html.DivElement()..text = "Tools";
  dropDown.append(text);

  html.DivElement items = new html.DivElement()..className = "dropdown-content";
  dropDown.append(items);

  addMenuItem(items, "Pan View", dvr.panView);
  addMenuItem(items, "Add Polygon 1", dvr.addPolygon1);
  addMenuItem(items, "Add Polygon 2", dvr.addPolygon2);
  addMenuItem(items, "Add Polygon 3", dvr.addPolygon3);
  addMenuItem(items, "Add Polygon 4", dvr.addPolygon4);
  addMenuItem(items, "Add Polygon 5", dvr.addPolygon5);
  addMenuItem(items, "Check Region", dvr.checkRegion);
  addMenuItem(items, "Validate", dvr.validate);
  addMenuItem(items, "Print Tree", dvr.printTree);
  addMenuItem(items, "Clear All", dvr.clearAll);
}

void addMenuItem(html.DivElement dropDownItems, String text, BoolValue value) {
  html.DivElement item = new html.DivElement()
    ..text = text
    ..className = (value.value ? "dropdown-item-active" : "dropdown-item-inactive")
    ..onClick.listen((_) {
      value.onClick();
    });
  value.onChange.add((bool value) {
    item.className = value ? "dropdown-item-active" : "dropdown-item-inactive";
  });
  dropDownItems.append(item);
}
