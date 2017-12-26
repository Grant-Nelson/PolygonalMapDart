library PolygonalMapDart.Plotter;

import 'dart:html' as html;

import 'package:PolygonalMapDart/Quadtree.dart' as qt;
import 'package:plotterDart/plotSvg.dart' as plotSvg;
import 'package:plotterDart/plotter.dart' as plotter;

part 'Quadtree.dart';

/// A plotter customized to work with quad-trees.
class QuadTreePlotter extends plotter.Plotter {
  /// Shows a quad-tree in a plot panel.
  static plotSvg.PlotSvg Show(qt.QuadTree tree, html.DivElement div,
      {bool showPassNodes = true,
      bool showPointNodes = true,
      bool showEmptyNodes = false,
      bool showBranchNodes = false,
      bool showEdges = true,
      bool showPoints = true,
      bool showBoundary = true,
      bool showRootBoundary = true}) {
    QuadTreePlotter plot = new QuadTreePlotter();
    plot.addTree(tree)
      ..showPassNodes = showPassNodes
      ..showPointNodes = showPointNodes
      ..showEmptyNodes = showEmptyNodes
      ..showBranchNodes = showBranchNodes
      ..showEdges = showEdges
      ..showPoints = showPoints
      ..showBoundary = showBoundary
      ..showRootBoundary = showRootBoundary;
    plot.updateBounds();
    plot.focusOnData();
    return new plotSvg.PlotSvg.fromElem(div, plot);
  }

  /// Adds a quad-tree plotter item with the given tree.
  QuadTree addTree(qt.QuadTree tree, [String label = "Tree"]) {
    QuadTree item = new QuadTree(tree, label);
    add([item]);
    return item;
  }

  /// Adds a point to the given point list.
  plotter.Points addPoint(plotter.Points points, qt.IPoint point) {
    if (points != null) {
      points.add([point.x.toDouble(), point.y.toDouble()]);
    }
    return points;
  }

  /// Adds a set of points to the given point list.
  plotter.Points addPointSet(plotter.Points points, Set<qt.PointNode> pointSet) {
    if (points != null) {
      for (qt.PointNode point in pointSet) points.add([point.x.toDouble(), point.y.toDouble()]);
    }
    return points;
  }

  /// Adds an edge to the given line list.
  plotter.Lines addLine(plotter.Lines lines, qt.IEdge edge) {
    if (lines != null) {
      lines.add([edge.x1.toDouble(), edge.y1.toDouble(), edge.x2.toDouble(), edge.y2.toDouble()]);
    }
    return lines;
  }

  /// Adds a boundary to the given rectangle list.
  plotter.Rectangles addBound(plotter.Rectangles rects, qt.Boundary bound, double inset) {
    double inset2 = 1.0 - inset * 2.0;
    rects.add([
      bound.xmin.toDouble() - inset,
      bound.ymin.toDouble() - inset,
      bound.width.toDouble() - inset2,
      bound.height.toDouble() - inset2
    ]);
    return rects;
  }
}
