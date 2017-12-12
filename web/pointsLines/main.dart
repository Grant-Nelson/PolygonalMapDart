library main;

import 'dart:html' as html;
import 'package:plotterDart/plotSvg.dart' as plotSvg;
import 'package:plotterDart/plotter.dart' as plotter;
import 'package:PolygonalMapDart/Quadtree.dart' as qt;

part 'driver.dart';

void main() {
  html.document.title = "Points & Lines";
  html.BodyElement body = html.document.body;
  
  html.DivElement menu = new html.DivElement();
  menu.className = "menu";
  body.append(menu);

  html.DivElement plotElem = new html.DivElement();
  plotElem.className = "plot_target";
  body.append(plotElem);

  plotter.Plotter plot = new plotter.Plotter();
  new plotSvg.PlotSvg.fromElem(plotElem, plot);
  Driver dvr = new Driver(plot);
  
  addMenuView(menu, dvr);
  addMenuTools(menu, dvr);
}

void addMenuView(html.DivElement menu, Driver dvr) {
  html.DivElement dropDown = new html.DivElement()
    ..className = "dropdown";
  menu.append(dropDown);
  
  html.DivElement text = new html.DivElement()
    ..text = "View";
  dropDown.append(text);

  html.DivElement items = new html.DivElement()
    ..className = "dropdown-content";
  dropDown.append(items);

  addMenuItem(items, "Points");
  addMenuItem(items, "Lines");
  addMenuItem(items, "Empty Nodes");
  addMenuItem(items, "Branch Nodes");
  addMenuItem(items, "Pass Nodes");
  addMenuItem(items, "Point Nodes");
}

void addMenuTools(html.DivElement menu, Driver dvr) {
  html.DivElement dropDown = new html.DivElement()
    ..className = "dropdown";
  menu.append(dropDown);

  html.DivElement text = new html.DivElement()
    ..text = "Tools";
  dropDown.append(text);

  html.DivElement items = new html.DivElement()
    ..className = "dropdown-content";
  dropDown.append(items);

  addMenuItem(items, "Add Points");
  addMenuItem(items, "Remove Points");
  addMenuItem(items, "Add Lines");
  addMenuItem(items, "Remove Lines");
}

void addMenuItem(html.DivElement dropDownItems, String text) {
  html.DivElement a = new html.DivElement()
    ..text = text;
  dropDownItems.append(a);
}
