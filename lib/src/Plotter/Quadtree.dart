part of PolygonalMapDart.Plotter;

/// A plotter customized to work with quad-trees.
class QuadTreePlotter extends plotter.Plotter {
  /// Shows a quad-tree in a plot panel.
  static plotSvg.PlotSvg Show(qt.QuadTree tree, html.DivElement div,
      {bool showPassNodes = true,
      bool showPointNodes = true,
      bool showEmptyNodes = false,
      bool showBranchNodes = false,
      bool showEdges = true,
      bool showPoints = true}) {
    QuadTreePlotter plot = new QuadTreePlotter();
    plot.addTree(tree)
      ..showPassNodes = showPassNodes
      ..showPointNodes = showPointNodes
      ..showEmptyNodes = showEmptyNodes
      ..showBranchNodes = showBranchNodes
      ..showEdges = showEdges
      ..showPoints = showPoints;
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

class QuadTree extends plotter.Group {
  qt.QuadTree _tree;

  plotter.Rectangles _passRects;
  plotter.Group _passRectsGroup;

  plotter.Rectangles _pointRects;
  plotter.Group _pointRectsGroup;

  plotter.Rectangles _emptyRects;
  plotter.Group _emptyRectsGroup;

  plotter.Rectangles _branchRects;
  plotter.Group _branchRectsGroup;

  plotter.Lines _edges;
  plotter.Group _edgesGroup;

  plotter.Points _points;
  plotter.Group _pointsGroup;

  /// Creates a new quad-tree plotter.
  QuadTree(this._tree, [String label = "Tree", bool enabled = true]) : super(label, enabled) {
    _passRects = new plotter.Rectangles();
    _passRects.addColor(0.0, 0.0, 0.6);
    _passRects.addFillColor(0.0, 0.0, 0.6, 0.3);
    _passRectsGroup = addGroup("Pass Nodes", [_passRects]);

    _pointRects = new plotter.Rectangles();
    _pointRects.addColor(0.0, 0.6, 0.2);
    _pointRects.addFillColor(0.0, 0.6, 0.2, 0.3);
    _pointRectsGroup = addGroup("Point Nodes", [_pointRects]);

    _emptyRects = new plotter.Rectangles();
    _emptyRects.addColor(0.8, 0.8, 0.0);
    _emptyRects.addFillColor(0.8, 0.8, 0.0, 0.3);
    _emptyRectsGroup = addGroup("Empty Nodes", [_emptyRects]) .. enabled = false;

    _branchRects = new plotter.Rectangles();
    _branchRects.addColor(0.0, 0.8, 0.0);
    _branchRects.addFillColor(0.0, 0.4, 0.8, 0.3);
    _branchRectsGroup = addGroup("Branch Nodes", [_branchRects])..enabled = false;

    _edges = new plotter.Lines();
    _edges.addColor(0.0, 0.0, 0.0);
    _edges.addDirected(true);
    _edgesGroup = addGroup("Lines", [_edges]);

    _points = new plotter.Points();
    _points.addPointSize(3.0);
    _points.addColor(0.0, 0.0, 0.0);
    _pointsGroup = addGroup("Points", [_points]);

    updateTree();
  }

  void set showPassNodes(bool value) {
    _passRectsGroup.enabled = value;
  }

  bool get showPassNodes => _passRectsGroup.enabled;

  void set showPointNodes(bool value) {
    _pointRectsGroup.enabled = value;
  }

  bool get showPointNodes => _pointRectsGroup.enabled;

  void set showEmptyNodes(bool value) {
    _emptyRectsGroup.enabled = value;
  }

  bool get showEmptyNodes => _emptyRectsGroup.enabled;

  void set showBranchNodes(bool value) {
    _branchRectsGroup.enabled = value;
  }

  bool get showBranchNodes => _branchRectsGroup.enabled;

  void set showEdges(bool value) {
    _edgesGroup.enabled = value;
  }

  bool get showEdges => _edgesGroup.enabled;

  void set showPoints(bool value) {
    _pointsGroup.enabled = value;
  }

  bool get showPoints => _pointsGroup.enabled;

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

  /// Updates a quad-tree to this plotter.
  void updateTree() {
    _passRects.clear();
    _pointRects.clear();
    _emptyRects.clear();
    _branchRects.clear();
    _edges.clear();
    _points.clear();

    if (_tree != null) {
      _tree.foreachNode(new _quadTreePlotterNodeHandler(this, _passRects, _pointRects, _emptyRects, _branchRects));

      if (_edges != null) {
        _tree.foreachEdge(new _quadTreePlotterEdgeHandler(this, _edges));
      }

      if (_points != null) {
        _tree.foreachPoint(new _quadTreePlotterPointHandler(this, _points));
      }
    }
  }
}

/// Handler for collecting all the nodes from the quadtree for plotting.
class _quadTreePlotterNodeHandler extends qt.INodeHandler {
  static const double _pad = 0.45;
  QuadTree _plot;
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
        for (qt.Quadrant quad in qt.Quadrant.All) {
          qt.INode child = node.child(quad);
          if (child is qt.EmptyNode) {
            double x = node.childX(quad).toDouble();
            double y = node.childY(quad).toDouble();
            double width = node.width / 2 - 1.0 + _pad * 2.0;
            _emptyRects.add([x - _pad, y - _pad, width, width]);
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
  QuadTree _plot;
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
  QuadTree _plot;
  plotter.Points _points;

  /// Creates a new quadtree plotter handler.
  _quadTreePlotterPointHandler(this._plot, this._points);

  /// Handles adding a new point into the plot.
  bool handle(qt.PointNode point) {
    _plot.addPoint(_points, point);
    return true;
  }
}
