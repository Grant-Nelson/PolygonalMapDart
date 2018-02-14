part of maps;

/// A tool for clipping polygons into simpler set of polygons.
class PolygonClipper {
  /// Cuts a complicated polygon wrapped in any order into
  /// CCW wrapped simpler set of polygons.
  static List<List<qt.IPoint>> Clip(List<qt.IPoint> pnts) {
    PolygonClipper clipper = new PolygonClipper._();
    clipper._setPolygon(pnts);
    clipper._getPolygons();
    return clipper._result;
  }

  qt.QuadTree _tree;
  List<List<qt.IPoint>> _result;

  /// Create a polygon clipper.
  PolygonClipper._() {
    _tree = new qt.QuadTree();
    _result = new List<List<qt.IPoint>>();
  }

  /// Sets the polygon to clip.
  void _setPolygon(List<qt.IPoint> pnts) {
    int count = pnts.length;
    if (count < 3) return;

    // Insert all the end points into the tree.
    qt.PointNodeVector nodes = new qt.PointNodeVector();
    for (int i = count - 1; i >= 0; --i) {
      qt.PointNode point = _insertPoint(pnts[i]);
      point.data = false;
      assert(point != null);
      nodes.nodes.add(point);
    }

    // Insert edges ignoring any degenerate ones.
    for (int i = pnts.length - 1; i >= 0; --i) {
      _insertEdge(nodes.edge(i));
    }
  }

  /// Gets all the polygons out of the quad-tree.
  void _getPolygons() {
    _tree.foreachEdge(new qt.EdgeMethodHandler(_tracePolygon));
  }

  /// Trace out a polygon starting from the given edge.
  bool _tracePolygon(qt.EdgeNode edge) {
    // If the data is true then this edge has already been handled so skip it.
    if (edge.data as bool) return true;

    // Trace polygon and mark edges as handled,
    // continue until the point has been reached before.
    qt.PointNodeVector pnts = new qt.PointNodeVector();
    List<qt.EdgeNode> edges = new List<qt.EdgeNode>();
    while(edge != null) {
      edge.data = true;
      qt.PointNode startPnt = edge.startNode;
      startPnt.data = true;
      pnts.nodes.add(startPnt);
      edges.add(edge);
      
      qt.PointNode endPnt = edge.endNode;
      if (endPnt.data as bool) {
        _popoffPolygon(pnts, edges, endPnt);
        if (pnts.nodes.length <= 0) return true;
        edge = edges.last;
      }
      edge = edge.nextBorder(new qt.EdgeMethodHandler(_ignoreMarkedEdges));
    }
    return true;
  }

  /// Removed the found polygon loop from the point stack.
  void _popoffPolygon(qt.PointNodeVector pnts, List<qt.EdgeNode> edges, qt.PointNode stopPnt) {
    // Read back to that point.
    for (int i = pnts.nodes.length-1; i >= 0; --i) {
      qt.PointNode pnt = pnts.nodes[i];
      if (stopPnt == pnt) {

        // Cut off sub-polygon.
        qt.PointNodeVector subpnts = new qt.PointNodeVector();
        subpnts.nodes.addAll(pnts.nodes.sublist(i));
        pnts.nodes.removeRange(i, pnts.nodes.length);
        edges.removeRange(i, edges.length);

        // Make sure the polygon is counter-clockwise.
        qt.AreaAccumulator area = subpnts.area;
        if (!area.ccw) subpnts.reverse();
        _result.add(subpnts.nodes);
        return;
      }
      pnt.data = false;
    }
  }

  /// Ignores any edges which have been marked.
  bool _ignoreMarkedEdges(qt.IEdge edge) {
    return !(edge.data as bool);
  }

  /// Inserts an edge into the tree and splits it for all instersections.
  void _insertEdge(qt.IEdge edge) {
    if (qt.Edge.degenerate(edge)) return;

    // Split edge for all near close points.
    qt.PointNode point = _tree.findClosePoint(edge, new qt.EdgePointIgnorer(edge));
    if (point != null) {
      _insertEdge(new qt.Edge(edge.start, point));
      _insertEdge(new qt.Edge(point, edge.end));
      return;
    }

    // Split edges which intersect.
    qt.IntersectionResult result = _tree.findFirstIntersection(edge, new qt.NeighborEdgeIgnorer(edge));
    if (result != null) {
      qt.PointNode point = _insertPoint(result.point);
      _insertEdge(new qt.Edge(edge.start, point));
      _insertEdge(new qt.Edge(point, edge.end));
      return;
    }

    // Insert the edge.
    qt.EdgeNode node = _tree.insertEdge(edge);
    node.data = false;
  }

  /// Inserts a point into the tree and collapses all near lines towards it.
  qt.PointNode _insertPoint(qt.IPoint pnt) {
    qt.InsertPointResult result = _tree.tryInsertPoint(pnt);
    if (result.existed) return result.point;

    // The point is new, check if any edges pass near it.
    Set<qt.EdgeNode> nearEdges = new Set<qt.EdgeNode>();
    _tree.forCloseEdges(new qt.EdgeCollectorHandle(edgeSet: nearEdges), pnt);

    // Remove near edges, store the replacement edges.
    Set<qt.Edge> liftedEdges = new Set<qt.Edge>();
    for (qt.EdgeNode edge in nearEdges) {
      liftedEdges.add(new qt.Edge(edge.startNode, result.point, edge.data));
      liftedEdges.add(new qt.Edge(result.point, edge.endNode, edge.data));
      _tree.removeEdge(edge, false);
    }

    // Adjust all the near lines.
    Set<qt.Edge> finalEdges = new Set<qt.Edge>();
    while (liftedEdges.isNotEmpty) {
      qt.IEdge edge = liftedEdges.last;
      liftedEdges.remove(edge);
      qt.PointNode point = _tree.findClosePoint(edge, new qt.EdgePointIgnorer(edge));
      if (point == null) {
        finalEdges.add(edge);
      } else {
        liftedEdges.add(new qt.Edge(edge.start, point, edge.data));
        liftedEdges.add(new qt.Edge(point, edge.end, edge.data));
      }
    }

    // Push the adjusted lines to the tree.
    for (qt.IEdge edge in finalEdges) {
      qt.EdgeNode node = _tree.insertEdge(edge);
      node.data = edge.data;
      assert(node != null);
    }
    return result.point;
  }
}
