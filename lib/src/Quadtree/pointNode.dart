part of PolygonalMapDart.Quadtree;

/// The point node represents a point in the quad-tree. It can have edges
/// starting or ending on it as well as edges which pass through it.
class PointNode extends BaseNode implements IPoint, Comparable<PointNode> {
  /// The first component (X) of the point.
  final int _x;

  /// The second component (Y) of the point.
  final int _y;

  /// The set of edges which start at this point.
  EdgeNodeSet _startEdges;

  /// The set of edges which end at this point.
  EdgeNodeSet _endEdges;

  /// The set of edges which pass through this node.
  EdgeNodeSet _passEdges;

  /// Any additional data that this point should contain.
  Object _data;

  /// Creates a new point node.
  PointNode(int this._x, int this._y) : super._() {
    this._startEdges = new EdgeNodeSet();
    this._endEdges = new EdgeNodeSet();
    this._passEdges = new EdgeNodeSet();
    this._data = null;
  }

  /// Gets the first integer coordinate component.
  int get x => this._x;

  /// Gets the second integer coordinate component.
  int get y => this._y;

  /// Gets the point for this node.
  Point get point => new Point(this._x, this._y);

  /// Gets the set of edges which start at this point.
  EdgeNodeSet get startEdges => this._startEdges;

  /// Gets the set of edges which end at this point.
  EdgeNodeSet get endEdges => this._endEdges;

  /// Gets the set of edges which pass through this node.
  EdgeNodeSet get passEdges => this._passEdges;

  /// Gets any additional data that this point should contain.
  Object get data => this._data;

  /// Sets additional data that this point should contain.
  void set data(Object data) {
    this._data = data;
  }

  /// Determines if this point is an orphan, meaning it's point isn't used by any edge.
  bool get orphan =>
      this._startEdges.nodes.isEmpty && this._endEdges.nodes.isEmpty;

  /// Finds an edge that starts at this point and ends at the given point.
  EdgeNode findEdgeToPoint(IPoint end) => this.findEdgeTo(end.x, end.y);

  /// Finds an edge that starts at this point and ends at the given point.
  EdgeNode findEdgeTo(int x, int y) {
    for (EdgeNode edge in this._startEdges.nodes) {
      if (Point.equalsPoint(edge.endNode, x, y)) return edge;
    }
    return null;
  }

  /// Finds an edge that ends at this point and starts at the given point.
  EdgeNode findEdgeFromPoint(IPoint start) =>
      this.findEdgeFrom(start.x, start.y);

  /// Finds an edge that ends at this point and starts at the given point.
  EdgeNode findEdgeFrom(int x, int y) {
    for (EdgeNode edge in this._endEdges.nodes) {
      if (Point.equalsPoint(edge.startNode, x, y)) return edge;
    }
    return null;
  }

  /// Finds an edge that starts or ends at this point and connects to the given point.
  EdgeNode findEdgeBetweenPoint(IPoint other) =>
      this.findEdgeBetween(other.x, other.y);

  /// Finds an edge that starts or ends at this point and connects to the given point.
  EdgeNode findEdgeBetween(int x, int y) {
    EdgeNode edge = this.findEdgeTo(x, y);
    if (edge == null) edge = this.findEdgeFrom(x, y);
    return edge;
  }

  /// Adds an edge to this node and/or children nodes.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  INode insertEdge(EdgeNode edge) {
    if (edge.startNode == this)
      this._startEdges.nodes.add(edge);
    else if (edge.endNode == this)
      this._endEdges.nodes.add(edge);
    else if (this.overlapsEdge(edge)) this._passEdges.nodes.add(edge);
    return this;
  }

  /// Adds a point to this node.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  INode insertPoint(PointNode point) {
    BranchNode branch = new BranchNode();
    branch.setLocation(this.xmin, this.ymin, this.width);
    int halfSize = this.width ~/ 2;

    // Make a copy of this node and set is as a child of the new branch.
    int childQuad = branch.childQuad(this._x, this._y);
    this.setLocation(
        branch.childX(childQuad), branch.childY(childQuad), halfSize);
    branch.setChild(childQuad, this);

    // Copy lines to new siblings, keep any non-empty sibling.
    for (int quad in Quadrant.All) {
      if (quad != childQuad) {
        PassNode sibling = new PassNode();
        sibling.setLocation(branch.childX(quad), branch.childY(quad), halfSize);
        this._appendPassingEdges(sibling, this._startEdges);
        this._appendPassingEdges(sibling, this._endEdges);
        this._appendPassingEdges(sibling, this._passEdges);
        if (!sibling.passEdges.nodes.isEmpty) branch.setChild(quad, sibling);
      }
    }

    // Remove any edges which no longer pass through this point.
    Iterator<EdgeNode> it = this._passEdges.nodes.iterator;
    Set<EdgeNode> remove = new Set<EdgeNode>();
    while (it.moveNext()) {
      EdgeNode edge = it.current;
      if (this.overlapsEdge(edge)) remove.add(edge);
    }
    this._passEdges.nodes.removeAll(remove);

    // Add the point to the new branch node, return new node.
    // This allows the branch to grow as needed.
    return branch.insertPoint(point);
  }

  /// This adds all the edges from the given set which pass through the given
  /// pass node to that node.
  void _appendPassingEdges(PassNode node, EdgeNodeSet edges) {
    for (EdgeNode edge in edges.nodes) {
      if (node.overlapsEdge(edge)) node.passEdges.nodes.add(edge);
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
      this._startEdges.nodes.remove(edge);
      if (trimTree && this.orphan) result = this.replacement;
    } else if (edge.endNode == this) {
      this._endEdges.nodes.remove(edge);
      if (trimTree && this.orphan) result = this.replacement;
    } else
      this._passEdges.nodes.remove(edge);
    return result;
  }

  /// This handles the first found intersecting edge.
  IntersectionResult findFirstIntersection(IEdge edge, IEdgeHandler hndl) {
    if (this.overlapsEdge(edge)) {
      IntersectionResult result;
      result = this._findFirstIntersection(this._startEdges, edge, hndl);
      if (result != null) return result;
      result = this._findFirstIntersection(this._endEdges, edge, hndl);
      if (result != null) return result;
      result = this._findFirstIntersection(this._passEdges, edge, hndl);
      if (result != null) return result;
    }
    return null;
  }

  /// This handles all the intersections.
  bool findAllIntersections(
      IEdge edge, IEdgeHandler hndl, IntersectionSet intersections) {
    bool result = false;
    if (this.overlapsEdge(edge)) {
      if (this._findAllIntersections(
          this._startEdges, edge, hndl, intersections)) result = true;
      if (this._findAllIntersections(this._endEdges, edge, hndl, intersections))
        result = true;
      if (this._findAllIntersections(
          this._passEdges, edge, hndl, intersections)) result = true;
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
  // exists even partially in the region are collected.
  bool foreachEdge(IEdgeHandler handle,
      [IBoundary bounds = null, bool exclusive = false]) {
    if ((bounds == null) || this.overlapsBoundary(bounds)) {
      if (exclusive) {
        // Check all edges which start at this node to see if they end in the bounds.
        // No need to check passEdges nor endEdges because for all exclusive edges
        // all startEdges lists will be checked at some point.
        for (EdgeNode edge in this._startEdges.nodes) {
          if (bounds.contains(edge.x2, edge.y2)) {
            if (!handle.handle(edge)) return false;
          }
        }
      } else {
        for (EdgeNode edge in this._startEdges.nodes) {
          if (!handle.handle(edge)) return false;
        }
        for (EdgeNode edge in this._endEdges.nodes) {
          if (!handle.handle(edge)) return false;
        }
        for (EdgeNode edge in this._passEdges.nodes) {
          if (!handle.handle(edge)) return false;
        }
      }
    }
    return true;
  }

  /// Handles each node reachable from this node in the boundary.
  bool foreachNode(INodeHandler handle, [IBoundary bounds = null]) {
    return ((bounds == null) || this.overlapsBoundary(bounds)) &&
        handle.handle(this);
  }

  /// Determines if the node has any point nodes inside it.
  /// Since this is a point node then it will always return true.
  bool get hasPoints => true;

  /// Determines if the node has any edge nodes inside it.
  bool get hasEdges => !(this._passEdges.nodes.isEmpty ||
      this._endEdges.nodes.isEmpty ||
      this._startEdges.nodes.isEmpty);

  /// Gets the first edge to the left of the given point.
  void firstLeftEdge(FirstLeftEdgeArgs args) {
    this._firstLineLeft(this._startEdges, args);
    this._firstLineLeft(this._endEdges, args);
    this._firstLineLeft(this._passEdges, args);
  }

  /// Handles all the edges to the left of the given point.
  bool foreachLeftEdge(IPoint point, IEdgeHandler handle) {
    if (!this._foreachLeftEdge(this._startEdges, point, handle)) return false;
    if (!this._foreachLeftEdge(this._endEdges, point, handle)) return false;
    if (!this._foreachLeftEdge(this._passEdges, point, handle)) return false;
    return true;
  }

  /// This finds the next point in the tree.
  PointNode nextPoint(IPointHandler handle, [IBoundary boundary = null]) {
    if (this.parent == null)
      return null;
    else
      return this.parent.findNextPoint(this, boundary, handle);
  }

  /// This finds the previous point in the tree.
  PointNode previousPoint(IPointHandler handle, [IBoundary boundary = null]) {
    if (this.parent == null)
      return null;
    else
      return this.parent.findPreviousPoint(this, boundary, handle);
  }

  /// This finds the nearest edge to the given point.
  /// When determining which edge should be considered the closest edge when the
  /// point for this node is the nearest point to the query point. This doesn't
  /// check passing edges, only beginning and ending edges because the nearest
  /// edge starts or ends at this node.
  EdgeNode nearEndEdge(IPoint queryPoint) {
    Edge queryEdge = new Edge(queryPoint.x, queryPoint.y, this.x, this.y);

    EdgeNode rightMost = null;
    EdgeNode leftMost = null;
    EdgeNode center = null;

    // Check all edges which start at this node.
    for (EdgeNode edge in this.startEdges.nodes) {
      IPoint pnt = edge.endNode;
      int side = Edge.side(queryEdge, pnt);
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
    for (EdgeNode edge in this.endEdges.nodes) {
      IPoint pnt = edge.startNode;
      int side = Edge.side(queryEdge, pnt);
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
        double rightCross = Point.cross(
            rightMost.x2 - this.x,
            rightMost.y2 - this.y,
            queryPoint.x - this.x,
            queryPoint.y - this.y);
        double leftCross = Point.cross(queryPoint.x - this.x,
            queryPoint.y - this.y, leftMost.x2 - this.x, leftMost.y2 - this.y);
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
    this.parent = null;

    // If there are no passing edges return an empty node.
    if (this._passEdges.nodes.isEmpty) return EmptyNode.instance;

    // Otherwise return a passing node with these passing edges.
    PassNode pass = new PassNode();
    pass.setLocation(this.xmin, this.ymin, this.width);
    pass.passEdges.nodes.addAll(this._passEdges.nodes);
    this._passEdges.nodes.clear();
    return pass;
  }

  /// Validates this node.
  bool validate(StringBuffer sout, final IFormatter format, bool recursive) {
    bool result = true;
    if (!this.contains(this._x, this._y)) {
      sout.write("Error in ");
      this.toBuffer(sout, format: format);
      sout.write(": The point is not contained by the node's region.\n");
      result = false;
    }

    for (EdgeNode edge in this._startEdges.nodes) {
      if (edge == null) {
        sout.write("Error in ");
        this.toBuffer(sout, format: format);
        sout.write(": A null line was in the starting list.\n");
        result = false;
      } else {
        if (edge.startNode != this) {
          sout.write("Error in ");
          this.toBuffer(sout, format: format);
          sout.write(": A line in the starting list, ");
          edge.toBuffer(sout, format: format);
          sout.write(", doesn't start with this node.\n");
          result = false;
        }
        if (edge.endNode == this) {
          sout.write("Error in ");
          this.toBuffer(sout, format: format);
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

    for (EdgeNode edge in this._endEdges.nodes) {
      if (edge == null) {
        sout.write("Error in ");
        this.toBuffer(sout, format: format);
        sout.write(": A null line was in the ending list.\n");
        result = false;
      } else {
        if (edge.endNode != this) {
          sout.write("Error in ");
          this.toBuffer(sout, format: format);
          sout.write(": A line in the ending list, ");
          edge.toBuffer(sout, format: format);
          sout.write(", doesn't end with this node.\n");
          result = false;
        }
        if (edge.startNode == this) {
          sout.write("Error in ");
          this.toBuffer(sout, format: format);
          sout.write(": A line in the ending list, ");
          edge.toBuffer(sout, format: format);
          sout.write(", also starts on this node.\n");
          result = false;
        }
      }
    }

    for (EdgeNode edge in this._passEdges.nodes) {
      if (edge == null) {
        sout.write("Error in ");
        this.toBuffer(sout, format: format);
        sout.write(": A null line was in the passing list.\n");
        result = false;
      } else {
        if (!this.overlapsEdge(edge)) {
          sout.write("Error in ");
          this.toBuffer(sout, format: format);
          sout.write(": A line in the passing list, ");
          edge.toBuffer(sout, format: format);
          sout.write(", doesn't pass through this node.\n");
          result = false;
        }
        if (edge.startNode == this) {
          sout.write("Error in ");
          this.toBuffer(sout, format: format);
          sout.write(": A line in the passing list, ");
          edge.toBuffer(sout, format: format);
          sout.write(", should be in the starting list.\n");
          result = false;
        }
        if (edge.endNode == this) {
          sout.write("Error in ");
          this.toBuffer(sout, format: format);
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
    if (this._y < other._y) return -1;
    if (this._y > other._y) return 1;
    if (this._x < other._x) return -1;
    if (this._x > other._x) return 1;
    return 0;
  }

  /// Formats the nodes into a string.
  /// [children] indicates any child should also be concatenated.
  /// [contained] indicates this node is part of another node.
  /// [last] indicates this is the last node of the parent.
  void toBuffer(StringBuffer sout,
      {String indent: "",
      bool children: false,
      bool contained: false,
      bool last: true,
      IFormatter format: null}) {
    if (contained) {
      if (last)
        sout.write(StringParts.Last);
      else
        sout.write(StringParts.Child);
    }

    sout.write("PointNode: ");
    sout.write(this.point.toString(format: format));
    sout.write(", ");
    sout.write(this.boundary.toString(format: format));
    if (this._data != null) {
      sout.write(" ");
      sout.write(this._data.toString());
    }

    if (children) {
      String childIndent;
      if (contained && !last)
        childIndent = indent + StringParts.Bar;
      else
        childIndent = indent + StringParts.Space;

      final bool hasStart = (this._startEdges.nodes.length > 0);
      final bool hasEnd = (this._endEdges.nodes.length > 0);
      final bool hasPass = (this._passEdges.nodes.length > 0);

      if (hasStart) {
        sout.write(StringParts.Sep);
        sout.write(indent);
        this._startEdges.toBuffer(sout,
            indent: childIndent,
            contained: true,
            last: !(hasEnd || hasPass),
            format: format);
      }
      if (hasEnd) {
        sout.write(StringParts.Sep);
        sout.write(indent);
        this._endEdges.toBuffer(sout,
            indent: childIndent,
            contained: true,
            last: !hasPass,
            format: format);
      }
      if (hasPass) {
        sout.write(StringParts.Sep);
        sout.write(indent);
        this._passEdges.toBuffer(sout,
            indent: childIndent, contained: true, last: true, format: format);
      }
    }
  }

  /// Determines if the given object is equal to this point.
  bool equals(Object o) {
    if (o == null) return false;
    if (o is PointNode) return false;
    return Point.equalPoints(this, o);
  }
}
