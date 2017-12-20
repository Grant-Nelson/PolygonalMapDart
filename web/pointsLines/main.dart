library main;

import 'dart:html' as html;
import 'package:plotterDart/plotSvg.dart' as plotSvg;
import 'package:PolygonalMapDart/Plotter.dart' as plotter;
import 'package:PolygonalMapDart/Quadtree.dart' as qt;

part 'driver.dart';
part 'boolValue.dart';

void main() {
  html.document.title = "Points & Lines";
  html.BodyElement body = html.document.body;

  html.DivElement menu = new html.DivElement();
  menu.className = "menu";
  body.append(menu);

  html.DivElement plotElem = new html.DivElement();
  plotElem.className = "plot_target";
  body.append(plotElem);

  plotter.QuadTreePlotter plot = new plotter.QuadTreePlotter();
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

  addMenuItem(items, "Points", dvr.points);
  addMenuItem(items, "Lines", dvr.lines);
  addMenuItem(items, "Empty Nodes", dvr.emptyNodes);
  addMenuItem(items, "Branch Nodes", dvr.branchNodes);
  addMenuItem(items, "Pass Nodes", dvr.passNodes);
  addMenuItem(items, "Point Nodes", dvr.pointNodes);
  addMenuItem(items, "Center View", dvr.centerView);
}

void addMenuTools(html.DivElement menu, Driver dvr) {
  html.DivElement dropDown = new html.DivElement()..className = "dropdown";
  menu.append(dropDown);

  html.DivElement text = new html.DivElement()..text = "Tools";
  dropDown.append(text);

  html.DivElement items = new html.DivElement()..className = "dropdown-content";
  dropDown.append(items);

  addMenuItem(items, "Add Points", dvr.addPoints);
  addMenuItem(items, "Remove Points", dvr.removePoints);
  addMenuItem(items, "Add Lines", dvr.addLines);
  addMenuItem(items, "Remove Lines", dvr.removeLines);
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
