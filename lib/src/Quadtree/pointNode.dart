part of PolygonalMapDart.Quadtree;

/// The point node represents a point in the quad-tree. It can have edges
/// starting or ending on it as well as edges which pass through it.
class PointNode extends BaseNode implements IPoint, Comparable<PointNode> {
  /// The first component (X) of the point.
  final int _x;

  /// The second component (Y) of the point.
  final int _y;

  /// The set of edges which start at this point.
  Set<EdgeNode> _startEdges;

  /// The set of edges which end at this point.
  Set<EdgeNode> _endEdges;

  /// The set of edges which pass through this node.
  Set<EdgeNode> _passEdges;

  /// Any additional data that this point should contain.
  Object _data;

  /// Creates a new point node.
  PointNode(this._x, this._y) : super._() {
    _startEdges = new Set<EdgeNode>();
    _endEdges = new Set<EdgeNode>();
    _passEdges = new Set<EdgeNode>();
    _data = null;
  }

  /// Gets the first integer coordinate component.
  int get x => _x;

  /// Gets the second integer coordinate component.
  int get y => _y;

  /// Gets the point for this node.
  Point get point => new Point(_x, _y);

  /// Gets the set of edges which start at this point.
  Set<EdgeNode> get startEdges => _startEdges;

  /// Gets the set of edges which end at this point.
  Set<EdgeNode> get endEdges => _endEdges;

  /// Gets the set of edges which pass through this node.
  Set<EdgeNode> get passEdges => _passEdges;

  /// Any additional data that this point should contain.
  Object get data => _data;
  set data(Object data) => _data = data;

  /// Determines if this point is an orphan, meaning it's point isn't used by any edge.
  bool get orphan => _startEdges.isEmpty && _endEdges.isEmpty;

  /// Finds an edge that starts at this point and ends at the given point.
  EdgeNode findEdgeTo(IPoint end) {
    for (EdgeNode edge in _startEdges) {
      if (Point.equals(edge.endNode, end)) return edge;
    }
    return null;
  }

  /// Finds an edge that ends at this point and starts at the given point.
  EdgeNode findEdgeFrom(IPoint start) {
    for (EdgeNode edge in _endEdges) {
      if (Point.equals(edge.startNode, start)) return edge;
    }
    return null;
  }

  /// Finds an edge that starts or ends at this point and connects to the given point.
  EdgeNode findEdgeBetween(IPoint other) {
    EdgeNode edge = findEdgeTo(other);
    if (edge == null) edge = findEdgeFrom(other);
    return edge;
  }

  /// Adds an edge to this node and/or children nodes.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  INode insertEdge(EdgeNode edge) {
    if (edge.startNode == this)
      _startEdges.add(edge);
    else if (edge.endNode == this)
      _endEdges.add(edge);
    else if (overlapsEdge(edge)) _passEdges.add(edge);
    return this;
  }

  /// Adds a point to this node.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  INode insertPoint(PointNode point) {
    BranchNode branch = new BranchNode();
    branch.setLocation(xmin, ymin, width);
    int halfSize = width ~/ 2;

    // Make a copy of this node and set is as a child of the new branch.
    Quadrant childQuad = branch.childQuad(this);
    setLocation(branch.childX(childQuad), branch.childY(childQuad), halfSize);
    branch.setChild(childQuad, this);

    // Copy lines to new siblings, keep any non-empty sibling.
    for (Quadrant quad in Quadrant.All) {
      if (quad != childQuad) {
        PassNode sibling = new PassNode();
        sibling.setLocation(branch.childX(quad), branch.childY(quad), halfSize);
        _appendPassingEdges(sibling, _startEdges);
        _appendPassingEdges(sibling, _endEdges);
        _appendPassingEdges(sibling, _passEdges);
        if (!sibling.passEdges.isEmpty) branch.setChild(quad, sibling);
      }
    }

    // Remove any edges which no longer pass through this point.
    Iterator<EdgeNode> it = _passEdges.iterator;
    Set<EdgeNode> remove = new Set<EdgeNode>();
    while (it.moveNext()) {
      EdgeNode edge = it.current;
      if (!overlapsEdge(edge)) remove.add(edge);
    }
    _passEdges.removeAll(remove);

    // Add the point to the new branch node, return new node.
    // This allows the branch to grow as needed.
    return branch.insertPoint(point);
  }

  /// This adds all the edges from the given set which pass through the given
  /// pass node to that node.
  void _appendPassingEdges(PassNode node, Set<EdgeNode> edges) {
    for (EdgeNode edge in edges) {
      if (node.overlapsEdge(edge)) node.passEdges.add(edge);
    }
  }

  /// Removes a edge from the tree at this node.
  /// [trimTree] indicates if the end points of the edge should be
  /// removed if no other edges begins or ends at that point.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  INode removeEdge(EdgeNode edge, bool trimTree) {
    INode result = this;
    if (edge.startNode == this) {
      _startEdges.remove(edge);
    } else if (edge.endNode == this) {
      _endEdges.remove(edge);
    } else
      _passEdges.remove(edge);
    return result;
  }

  /// This handles the first found intersecting edge.
  IntersectionResult findFirstIntersection(IEdge edge, IEdgeHandler hndl) {
    if (overlapsEdge(edge)) {
      IntersectionResult result;
      result = _findFirstIntersection(_startEdges, edge, hndl);
      if (result != null) return result;
      result = _findFirstIntersection(_endEdges, edge, hndl);
      if (result != null) return result;
      result = _findFirstIntersection(_passEdges, edge, hndl);
      if (result != null) return result;
    }
    return null;
  }

  /// This handles all the intersections.
  bool findAllIntersections(IEdge edge, IEdgeHandler hndl, IntersectionSet intersections) {
    bool result = false;
    if (overlapsEdge(edge)) {
      if (_findAllIntersections(_startEdges, edge, hndl, intersections)) result = true;
      if (_findAllIntersections(_endEdges, edge, hndl, intersections)) result = true;
      if (_findAllIntersections(_passEdges, edge, hndl, intersections)) result = true;
    }
    return result;
  }

  /// Handles each point node reachable from this node in the boundary.
  bool foreachPoint(IPointHandler handle, [IBoundary bounds = null]) {
    if ((bounds == null) || bounds.containsPoint(this)) {
      return handle.handle(this);
    } else
      return true;
  }

  /// Handles each edge node reachable from this node in the boundary.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  /// exists even partially in the region are collected.
  bool foreachEdge(IEdgeHandler handle, [IBoundary bounds = null, bool exclusive = false]) {
    if (bounds == null) {
      for (EdgeNode edge in _startEdges) {
        if (!handle.handle(edge)) return false;
      }
    } else if (overlapsBoundary(bounds)) {
      if (exclusive) {
        // Check all edges which start at this node to see if they end in the bounds.
        // No need to check passEdges nor endEdges because for all exclusive edges
        // all startEdges lists will be checked at some point.
        for (EdgeNode edge in _startEdges) {
          if (bounds.containsPoint(edge.end)) {
            if (!handle.handle(edge)) return false;
          }
        }
      } else {
        for (EdgeNode edge in _startEdges) {
          if (!handle.handle(edge)) return false;
        }
        for (EdgeNode edge in _endEdges) {
          if (!handle.handle(edge)) return false;
        }
        for (EdgeNode edge in _passEdges) {
          if (!handle.handle(edge)) return false;
        }
      }
    }
    return true;
  }

  /// Handles each node reachable from this node in the boundary.
  bool foreachNode(INodeHandler handle, [IBoundary bounds = null]) {
    return ((bounds == null) || overlapsBoundary(bounds)) && handle.handle(this);
  }

  /// Determines if the node has any point nodes inside it.
  /// Since this is a point node then it will always return true.
  bool get hasPoints => true;

  /// Determines if the node has any edge nodes inside it.
  bool get hasEdges => !(_passEdges.isEmpty || _endEdges.isEmpty || _startEdges.isEmpty);

  /// Gets the first edge to the left of the given point.
  void firstLeftEdge(FirstLeftEdgeArgs args) {
    _firstLineLeft(_startEdges, args);
    _firstLineLeft(_endEdges, args);
    _firstLineLeft(_passEdges, args);
  }

  /// Handles all the edges to the left of the given point.
  bool foreachLeftEdge(IPoint point, IEdgeHandler handle) {
    if (!_foreachLeftEdge(_startEdges, point, handle)) return false;
    if (!_foreachLeftEdge(_endEdges, point, handle)) return false;
    if (!_foreachLeftEdge(_passEdges, point, handle)) return false;
    return true;
  }

  /// This finds the next point in the tree.
  PointNode nextPoint(IPointHandler handle, [IBoundary boundary = null]) {
    if (parent == null) return null;
    return parent.findNextPoint(this, boundary, handle);
  }

  /// This finds the previous point in the tree.
  PointNode previousPoint(IPointHandler handle, [IBoundary boundary = null]) {
    if (parent == null) return null;
    return parent.findPreviousPoint(this, boundary, handle);
  }

  /// This finds the nearest edge to the given point.
  /// When determining which edge should be considered the closest edge when the
  /// point for this node is the nearest point to the query point. This doesn't
  /// check passing edges, only beginning and ending edges because the nearest
  /// edge starts or ends at this node.
  EdgeNode nearEndEdge(IPoint queryPoint) {
    Edge queryEdge = new Edge(queryPoint, this);

    EdgeNode rightMost = null;
    EdgeNode leftMost = null;
    EdgeNode center = null;

    // Check all edges which start at this node.
    for (EdgeNode edge in startEdges) {
      IPoint pnt = edge.endNode;
      Side side = Edge.side(queryEdge, pnt);
      if (side == Side.Right) {
        if ((rightMost == null) || (Edge.side(rightMost, pnt) == Side.Right)) {
          rightMost = edge;
        }
      } else if (side == Side.Left) {
        if ((leftMost == null) || (Edge.side(leftMost, pnt) == Side.Left)) {
          leftMost = edge;
        }
      } else {
        // (side == Side.Inside)
        center = edge;
      }
    }

    // Check all edges which end at this node.
    for (EdgeNode edge in endEdges) {
      IPoint pnt = edge.startNode;
      Side side = Edge.side(queryEdge, pnt);
      if (side == Side.Right) {
        if ((rightMost == null) || (Edge.side(rightMost, pnt) == Side.Right)) {
          rightMost = edge;
        }
      } else if (side == Side.Left) {
        if ((leftMost == null) || (Edge.side(leftMost, pnt) == Side.Left)) {
          leftMost = edge;
        }
      } else {
        // (side == Side.Inside)
        center = edge;
      }
    }

    // Determine the closest side of the found sides.
    if (rightMost != null) {
      if (leftMost != null) {
        double rightCross =
            Point.cross(new Point(rightMost.x2 - x, rightMost.y2 - y), new Point(queryPoint.x - x, queryPoint.y - y));
        double leftCross =
            Point.cross(new Point(queryPoint.x - x, queryPoint.y - y), new Point(leftMost.x2 - x, leftMost.y2 - y));
        if (rightCross <= leftCross)
          return rightMost;
        else
          return leftMost;
      } else
        return rightMost;
    } else if (leftMost != null)
      return leftMost;
    else
      return center;
  }

  /// Determines the replacement node when a point is removed.
  INode get replacement {
    parent = null;

    // If there are no passing edges return an empty node.
    if (_passEdges.isEmpty) return EmptyNode.instance;

    // Otherwise return a passing node with these passing edges.
    PassNode pass = new PassNode();
    pass.setLocation(xmin, ymin, width);
    pass.passEdges.addAll(_passEdges);
    _passEdges.clear();
    return pass;
  }

  /// Validates this node.
  bool validate(StringBuffer sout, final IFormatter format, bool recursive) {
    bool result = true;
    if (!containsPoint(this)) {
      sout.write("Error in ");
      toBuffer(sout, format: format);
      sout.write(": The point is not contained by the node's region.\n");
      result = false;
    }

    for (EdgeNode edge in _startEdges) {
      if (edge == null) {
        sout.write("Error in ");
        toBuffer(sout, format: format);
        sout.write(": A null line was in the starting list.\n");
        result = false;
      } else {
        if (edge.startNode != this) {
          sout.write("Error in ");
          toBuffer(sout, format: format);
          sout.write(": A line in the starting list, ");
          edge.toBuffer(sout, format: format);
          sout.write(", doesn't start with this node.\n");
          result = false;
        }
        if (edge.endNode == this) {
          sout.write("Error in ");
          toBuffer(sout, format: format);
          sout.write(": A line in the starting list, ");
          edge.toBuffer(sout, format: format);
          sout.write(", also ends on this node.\n");
          result = false;
        }
        if (recursive) {
          if (!edge.validate(sout, format)) result = false;
        }
      }
    }

    for (EdgeNode edge in _endEdges) {
      if (edge == null) {
        sout.write("Error in ");
        toBuffer(sout, format: format);
        sout.write(": A null line was in the ending list.\n");
        result = false;
      } else {
        if (edge.endNode != this) {
          sout.write("Error in ");
          toBuffer(sout, format: format);
          sout.write(": A line in the ending list, ");
          edge.toBuffer(sout, format: format);
          sout.write(", doesn't end with this node.\n");
          result = false;
        }
        if (edge.startNode == this) {
          sout.write("Error in ");
          toBuffer(sout, format: format);
          sout.write(": A line in the ending list, ");
          edge.toBuffer(sout, format: format);
          sout.write(", also starts on this node.\n");
          result = false;
        }
      }
    }

    for (EdgeNode edge in _passEdges) {
      if (edge == null) {
        sout.write("Error in ");
        toBuffer(sout, format: format);
        sout.write(": A null line was in the passing list.\n");
        result = false;
      } else {
        if (!overlapsEdge(edge)) {
          sout.write("Error in ");
          toBuffer(sout, format: format);
          sout.write(": A line in the passing list, ");
          edge.toBuffer(sout, format: format);
          sout.write(", doesn't pass through this node.\n");
          result = false;
        }
        if (edge.startNode == this) {
          sout.write("Error in ");
          toBuffer(sout, format: format);
          sout.write(": A line in the passing list, ");
          edge.toBuffer(sout, format: format);
          sout.write(", should be in the starting list.\n");
          result = false;
        }
        if (edge.endNode == this) {
          sout.write("Error in ");
          toBuffer(sout, format: format);
          sout.write(": A line in the passing list, ");
          edge.toBuffer(sout, format: format);
          sout.write(", should be in the ending list.\n");
          result = false;
        }
      }
    }

    return result;
  }

  /// Compares the given point with this point.
  /// Return 1 if this point is greater than the other point,
  /// -1 if this point is less than the other point,
  /// 0 if this point is the same as the other point.
  int compareTo(PointNode other) {
    if (_y < other._y) return -1;
    if (_y > other._y) return 1;
    if (_x < other._x) return -1;
    if (_x > other._x) return 1;
    return 0;
  }

  /// Formats the nodes into a string.
  /// [children] indicates any child should also be concatenated.
  /// [contained] indicates this node is part of another node.
  /// [last] indicates this is the last node of the parent.
  void toBuffer(StringBuffer sout,
      {String indent: "", bool children: false, bool contained: false, bool last: true, IFormatter format: null}) {
    if (contained) {
      if (last)
        sout.write(StringParts.Last);
      else
        sout.write(StringParts.Child);
    }

    sout.write("PointNode: ");
    sout.write(point.toString(format: format));
    sout.write(", ");
    sout.write(boundary.toString(format: format));
    if (_data != null) {
      sout.write(" ");
      sout.write(_data.toString());
    }

    if (children) {
      String childIndent;
      if (contained && !last)
        childIndent = indent + StringParts.Bar;
      else
        childIndent = indent + StringParts.Space;

      final bool hasStart = (_startEdges.length > 0);
      final bool hasEnd = (_endEdges.length > 0);
      final bool hasPass = (_passEdges.length > 0);

      if (hasStart) {
        sout.write(StringParts.Sep);
        sout.write(indent);
        Edge.edgeNodesToBuffer(_startEdges, sout,
            indent: childIndent, contained: true, last: !(hasEnd || hasPass), format: format);
      }
      if (hasEnd) {
        sout.write(StringParts.Sep);
        sout.write(indent);
        Edge.edgeNodesToBuffer(_endEdges, sout, indent: childIndent, contained: true, last: !hasPass, format: format);
      }
      if (hasPass) {
        sout.write(StringParts.Sep);
        sout.write(indent);
        Edge.edgeNodesToBuffer(_passEdges, sout, indent: childIndent, contained: true, last: true, format: format);
      }
    }
  }
}
