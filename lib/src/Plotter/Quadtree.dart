part of PolygonalMapDart.Plotter;

/// A plotter customized to work with quad-trees.
class QuadTreePlotter extends plotter.Plotter {
  /// Shows a quad-tree in a plot panel.
  static plotSvg.PlotSvg Show(qt.QuadTree tree, html.DivElement div) {
    QuadTreePlotter plot = new QuadTreePlotter();
    plotter.Group grp = plot.addGroup("Tree");
    plot.addTree(grp, tree);
    plot.updateBounds();
    plot.focusOnData();
    return new plotSvg.PlotSvg.fromElem(div, plot);
  }

  /// Creates a new quad-tree plotter.
  QuadTreePlotter() : super();

  /// Adds a point to the given point list.
  plotter.Points addPoint(plotter.Points points, qt.IPoint point) {
    if (points != null) points.add([point.x.toDouble(), point.y.toDouble()]);
    return points;
  }

  /// Adds a set of points to the given point list.
  plotter.Points addPointSet(plotter.Points points, Set<qt.PointNode> pointSet) {
    for (qt.PointNode point in pointSet) {
      points.add([point.x.toDouble(), point.y.toDouble()]);
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
    if (rects != null) {
      double inset2 = 1.0 - inset * 2.0;
      rects.add([
        bound.xmin.toDouble() - inset,
        bound.ymin.toDouble() - inset,
        bound.width.toDouble() - inset2,
        bound.height.toDouble() - inset2
      ]);
    }
    return rects;
  }

  /// Adds a quad-tree to this plotter.
  plotter.Group addTreeGroup(String label, qt.QuadTree tree) {
    plotter.Group group = addGroup(label);
    addTree(group, tree, true, true, false, false, true, true);
    return group;
  }

  /// Adds a quad-tree to this plotter.
  void addTree(plotter.Group group, qt.QuadTree tree,
      [bool showPassNodes = true,
      bool showPointNodes = true,
      bool showEmptyNodes = false,
      bool showBranchNodes = false,
      bool showEdges = true,
      bool showPoints = true]) {
    plotter.Rectangles passRects = new plotter.Rectangles();
    passRects.addColor(0.0, 0.0, 0.6);
    passRects.addFillColor(0.0, 0.0, 0.6, 0.3);
    group.addGroup("Pass Nodes", [passRects])..enabled = showPassNodes;

    plotter.Rectangles pointRects = new plotter.Rectangles();
    pointRects.addColor(0.0, 0.6, 0.2);
    pointRects.addFillColor(0.0, 0.6, 0.2, 0.3);
    group.addGroup("Point Nodes", [pointRects])..enabled = showPointNodes;

    plotter.Rectangles emptyRects = new plotter.Rectangles();
    emptyRects.addColor(0.8, 0.8, 0.0);
    emptyRects.addFillColor(0.8, 0.8, 0.0, 0.3);
    group.addGroup("Empty Nodes", [emptyRects])..enabled = showEmptyNodes;

    plotter.Rectangles branchRects = new plotter.Rectangles();
    branchRects.addColor(0.0, 0.8, 0.0);
    branchRects.addFillColor(0.0, 0.4, 0.8, 0.3);
    group.addGroup("Branch Nodes", [branchRects])..enabled = showBranchNodes;

    plotter.Lines edges = new plotter.Lines();
    edges.addColor(0.0, 0.0, 0.0);
    edges.addDirected(true);
    group.addGroup("Lines", [edges])..enabled = showEdges;

    plotter.Points points = new plotter.Points();
    points.addPointSize(3.0);
    points.addColor(0.0, 0.0, 0.0);
    group.addGroup("Points", [points])..enabled = showPoints;

    addTreeItems(tree, passRects, pointRects, emptyRects, branchRects, edges, points);
  }

  /// Adds a quad-tree to this plotter.
  /// Plotter parts can be null to not add to the plot.
  void addTreeItems(qt.QuadTree tree, plotter.Rectangles passRects, plotter.Rectangles pointRects,
      plotter.Rectangles emptyRects, plotter.Rectangles branchRects, plotter.Lines edges, plotter.Points points) {
    tree.foreachNode(new _quadTreePlotterNodeHandler(this, passRects, pointRects, emptyRects, branchRects));

    if (edges != null) {
      tree.foreachEdge(new _quadTreePlotterEdgeHandler(this, edges));
    }

    if (points != null) {
      tree.foreachPoint(new _quadTreePlotterPointHandler(this, points));
    }
  }
}

/// Handler for collecting all the nodes from the quadtree for plotting.
class _quadTreePlotterNodeHandler extends qt.INodeHandler {
  static const double _pad = 0.45;
  QuadTreePlotter _plot;
  plotter.Rectangles _passRects;
  plotter.Rectangles _pointRects;
  plotter.Rectangles _emptyRects;
  plotter.Rectangles _branchRects;

  /// Creates a new quadtree plotter handler.
  _quadTreePlotterNodeHandler(this._plot, this._passRects, this._pointRects, this._emptyRects, this._branchRects);

  /// Handles adding a new node into the plot.
  bool handle(qt.INode node) {
    if (node is qt.PassNode) {
      _plot.addBound(_passRects, node.boundary, _pad);
    } else if (node is qt.PointNode) {
      _plot.addBound(_pointRects, node.boundary, _pad);
    } else if (node is qt.BranchNode) {
      if (_emptyRects != null) {
        for (int quad in qt.Quadrant.All) {
          qt.INode child = node.child(quad);
          if (child is qt.EmptyNode) {
            double width = node.width / 2 - 1.0 + _pad * 2.0;
            _emptyRects.add([node.childX(quad) - _pad, node.childY(quad) - _pad, width, width]);
          }
        }
      }
      _plot.addBound(_branchRects, node.boundary, _pad);
    }
    return true;
  }
}

/// Handler for collecting all the edges from the quadtree for plotting.
class _quadTreePlotterEdgeHandler extends qt.IEdgeHandler {
  QuadTreePlotter _plot;
  plotter.Lines _edges;

  /// Creates a new quadtree plotter handler.
  _quadTreePlotterEdgeHandler(this._plot, this._edges);

  /// Handles adding a new edge into the plot.
  bool handle(qt.EdgeNode edge) {
    _plot.addLine(_edges, edge);
    return true;
  }
}

/// Handler for collecting all the points from the quadtree for plotting.
class _quadTreePlotterPointHandler extends qt.IPointHandler {
  QuadTreePlotter _plot;
  plotter.Points _points;

  /// Creates a new quadtree plotter handler.
  _quadTreePlotterPointHandler(this._plot, this._points);

  /// Handles adding a new point into the plot.
  bool handle(qt.PointNode point) {
    _plot.addPoint(_points, point);
    return true;
  }
}
