part of maps;

/// A map of regions.
/// Useful for defining country, state, and zone maps,
/// topographical  maps, or other distinct bounded area maps.
class Regions {
  /// The tree storing the regions.
  qt.QuadTree _tree;

  /// Creates a new region map.
  Regions() {
    _tree = new qt.QuadTree();
  }

  /// Gets the tree storing the regions.
  qt.QuadTree get tree => _tree;

  /// Determines the region that the point is inside of.
  int getRegion(qt.IPoint pnt) {
    qt.EdgeNode node = this._tree.firstLeftEdge(pnt);
    if (node == null) return 0;
    EdgeSide sideData = node.data;
    if (qt.Edge.side(node, pnt) == qt.Side.Left)
      return sideData.left;
    else
      return sideData.right;
  }

  /// Adds a region into the map.
  /// Note: The region will overwrite any region contained in it.
  /// The given [pntCoords] are the x and y pairs for the points of the
  /// simple polygon for the region.
  void addRegionWithCoords(int regionId, List<int> pntCoords) {
    int count = pntCoords.length ~/ 2;
    List<qt.IPoint> pnts = new List<qt.IPoint>(count);
    for (int i = 0; i < count; ++i) {
      pnts[i] = new qt.Point(pntCoords[i * 2], pntCoords[i * 2 + 1]);
    }
    addRegion(regionId, pnts);
  }

  /// Adds a region into the map.
  /// Note: The region will overwrite any region contained in it.
  void addRegion(int regionId, List<qt.IPoint> pnts) {
    // Insert all the end points into the tree.
    int count = pnts.length;
    qt.PointNodeVector nodes = new qt.PointNodeVector();
    for (int i = count - 1; i >= 0; --i) {
      qt.PointNode point = _insertPoint(pnts[i]);
      assert(point != null);
      nodes.nodes.add(point);
    }

    // Find all near points to the new edges.
    for (int i = 0; i < count; ++i) {
      qt.Edge edge = nodes.edge(i);
      qt.PointNode point = _tree.findClosePoint(edge, new qt.EdgePointIgnorer(edge));
      if (point != null) {
        nodes.nodes.insert(i + 1, point);
        ++count;
        --i;
      }
    }

    // Find all edge intersections.
    for (int i = 0; i < count; ++i) {
      qt.Edge edge = nodes.edge(i);
      qt.IntersectionResult result = _tree.findFirstIntersection(edge, new qt.NeighborEdgeIgnorer(edge));
      if ((result != null) && result.intersects) {
        qt.PointNode point = _insertPoint(result.point);
        nodes.nodes.insert(i + 1, point);
        ++count;
        --i;
      }
    }

    // Make sure the polygon is counter-clockwise.
    qt.AreaAccumulator area = nodes.area;
    if (!area.ccw) nodes.reverse();

    // Remove any contained data.
    // Create a tree which contains the input so it can be queried.
    qt.QuadTree newRegion = new qt.QuadTree();
    for (int i = 0; i < count; ++i) {
      newRegion.insertEdge(nodes.edge(i));
    }
    _removeContainedPoints(newRegion);
    _removeContainedEdges(newRegion);

    // Insert the edges of the boundary while checking the outside boundary region value.
    for (int i = 0; i < count; ++i) {
      qt.Edge edge = nodes.edge(i);
      qt.PointNode start = edge.start;
      qt.PointNode end = edge.end;

      qt.EdgeNode last = start.findEdgeTo(end);
      if (last != null) {
        EdgeSide sideData = last.data;
        assert(sideData != null);
        sideData.left = regionId;
      } else {
        last = end.findEdgeTo(start);
        if (last != null) {
          EdgeSide sideData = last.data;
          assert(sideData != null);
          sideData.right = regionId;
        } else {
          int outterRangeId = _getSide(start, end);
          qt.EdgeNode e = _tree.insertEdge(edge);
          e.data = new EdgeSide(regionId, outterRangeId);
        }
      }
    }
  }

  /// Removes the points (and edges connected to those points)
  /// contained within the given region.
  void _removeContainedPoints(qt.QuadTree newRegion) {
    _PointRemover pntRemover = new _PointRemover(newRegion);
    _tree.foreachPoint(pntRemover, newRegion.boundary);

    // Remove all the inner edges and points.
    for (qt.PointNode node in pntRemover.remove) _tree.removePoint(node);
  }

  /// Removes all edges contained in the region.
  void _removeContainedEdges(qt.QuadTree newRegion) {
    _EdgeRemover edgeRemover = new _EdgeRemover(newRegion);
    _tree.foreachEdge(edgeRemover, newRegion.boundary, true);

    // Remove all the inner edges and points.
    for (qt.EdgeNode node in edgeRemover.remove) _tree.removeEdge(node, false);
  }

  /// Gets the right side value for the given edge.
  /// The given [start] is the start point of the edge to get the side for.
  /// The given [end] is the end point of the edge to get the side for.
  int _getSide(qt.PointNode start, qt.PointNode end) {
    qt.BorderNeighbor border = new qt.BorderNeighbor.Points(start, end, true, null);
    for (qt.EdgeNode neighbor in end.startEdges) {
      border.handle(neighbor);
    }
    for (qt.EdgeNode neighbor in end.endEdges) {
      border.handle(neighbor);
    }
    qt.EdgeNode next = border.result;
    if (next != null) {
      EdgeSide sideData = next.data;
      if (next.startNode == end)
        return sideData.right;
      else
        return sideData.left;
    }

    border = new qt.BorderNeighbor.Points(end, start, false, null);
    for (qt.EdgeNode neighbor in start.startEdges) {
      border.handle(neighbor);
    }
    for (qt.EdgeNode neighbor in start.endEdges) {
      border.handle(neighbor);
    }
    qt.EdgeNode previous = border.result;
    if (previous != null) {
      EdgeSide sideData = previous.data;
      if (previous.endNode == start)
        return sideData.right;
      else
        return sideData.left;
    }

    return 0;
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
    Set<qt.Edge> pushEdges = new Set<qt.Edge>();
    while (liftedEdges.isNotEmpty) {
      qt.IEdge edge = liftedEdges.last;
      liftedEdges.remove(edge);
      qt.PointNode point = _tree.findClosePoint(edge, new qt.EdgePointIgnorer(edge));
      if (point == null) {
        pushEdges.add(edge);
      } else {
        liftedEdges.add(new qt.Edge(edge.start, point, edge.data));
        liftedEdges.add(new qt.Edge(point, edge.end, edge.data));
      }
    }

    // Reduce all edges which are coincident.
    Set<qt.Edge> finalEdges = new Set<qt.Edge>();
    while (!pushEdges.isEmpty) {
      qt.IEdge edge = pushEdges.last;
      pushEdges.remove(edge);
      _reduceEdge(pushEdges, finalEdges, edge);
    }

    // Push the adjusted lines to the tree.
    for (qt.IEdge edge in finalEdges) {
      qt.EdgeNode node = _tree.insertEdge(edge);
      node.data = new EdgeSide.copy(edge.data);
    }

    return result.point;
  }

  /// Reduces a set of edges to the minimum required edges.
  /// The [pushEdges] are the edges to reduce.
  /// The [finalEdges] are the minimum required edges.
  /// The [edge] is the edge to reduce towards.
  void _reduceEdge(Set<qt.Edge> pushEdges, Set<qt.Edge> finalEdges, qt.IEdge edge) {
    List<int> lefts = new List<int>();
    List<int> rights = new List<int>();
    EdgeSide sideData = edge.data;
    lefts.add(sideData.left);
    rights.add(sideData.right);

    // Check the tree for an existing line.
    qt.PointNode start = edge.start;
    qt.EdgeNode treeEdge = start.findEdgeTo(edge.end);
    if (treeEdge != null) {
      sideData = treeEdge.data;
      lefts.add(sideData.left);
      rights.add(sideData.right);
    } else {
      treeEdge = start.findEdgeFrom(edge.end);
      if (treeEdge != null) {
        sideData = treeEdge.data;
        lefts.add(sideData.right);
        rights.add(sideData.left);
      }
    }

    // Check for all other coincident edges.
    Iterator<qt.IEdge> it = pushEdges.iterator;
    List<qt.IEdge> removeEdge = new List<qt.IEdge>();
    while (it.moveNext()) {
      qt.IEdge edge2 = it.current;
      sideData = edge2.data;
      if (qt.Edge.equals(edge, edge2, false)) {
        lefts.add(sideData.left);
        rights.add(sideData.right);
        removeEdge.add(edge2);
      } else if (qt.Edge.opposites(edge, edge2)) {
        lefts.add(sideData.right);
        rights.add(sideData.left);
        removeEdge.add(edge2);
      }
    }
    pushEdges.removeAll(removeEdge);

    // Reduce all edges side values.
    for (int i = lefts.length - 1; i >= 0; --i) {
      for (int j = rights.length - 1; j >= 0; --j) {
        if (lefts[i] == rights[j]) {
          lefts.removeAt(i);
          rights.removeAt(j);
          break;
        }
      }
    }

    // Create final edge.
    if (!(lefts.isEmpty || rights.isEmpty)) {
      edge.data = new EdgeSide(lefts[0], rights[0]);
      finalEdges.add(edge);
    }
  }
}

/// Collect all points inside the polygon.
class _PointRemover implements qt.IPointHandler {
  qt.QuadTree _region;
  Set<qt.PointNode> _remove;

  _PointRemover(this._region) {
    _remove = new Set<qt.PointNode>();
  }

  Set<qt.PointNode> get remove => _remove;

  bool handle(qt.PointNode point) {
    qt.EdgeNode edge = _region.firstLeftEdge(point);
    if (edge != null) {
      if (qt.Edge.side(edge, point) == qt.Side.Left) {
        _remove.add(point);
      }
    }
    return true;
  }
}

/// Collect all edges inside the polygon.
class _EdgeRemover implements qt.IEdgeHandler {
  qt.QuadTree _region;
  Set<qt.EdgeNode> _remove;

  _EdgeRemover(this._region) {
    _remove = new Set<qt.EdgeNode>();
  }

  Set<qt.EdgeNode> get remove => _remove;

  bool handle(qt.EdgeNode edge) {
    qt.Point center = new qt.Point(edge.x1 + edge.dx ~/ 2, edge.y1 + edge.dy ~/ 2);
    if (qt.Point.equals(edge.start, center) || qt.Point.equals(edge.end, center)) {
      // Determine if the edge is inside.
      // If both points are not on the region edge then it is outside
      // because all inside points have been removed.
      qt.PointNode start = _region.findPoint(edge.start);
      if (start == null) return true;
      qt.PointNode end = _region.findPoint(edge.end);
      if (end == null) return true;

      // If edge is one of the region edges ignore it for now.
      if (start.findEdgeBetween(end) != null) return true;

      // Find nearest edge on region.
      qt.BorderNeighbor border = new qt.BorderNeighbor.Points(end, start, false, null);
      for (qt.EdgeNode neighbor in start.startEdges) {
        border.handle(neighbor);
      }
      for (qt.EdgeNode neighbor in start.endEdges) {
        border.handle(neighbor);
      }
      qt.EdgeNode regionEdge = border.result;
      if (regionEdge != null) {
        if (regionEdge.endNode != start) {
          _remove.add(edge);
        }
      }
    } else {
      qt.EdgeNode first = _region.firstLeftEdge(center);
      if (first != null) {
        if (qt.Edge.side(first, center) == qt.Side.Left) {
          _remove.add(edge);
        }
      }
    }
    return true;
  }
}
