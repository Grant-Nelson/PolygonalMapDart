part of PolygonalMapDart.Quadtree;

/// The point node represents a point in the quad-tree. It can have edges
/// starting or ending on it as well as edges which pass through it.
class PointNode extends BaseNode implements IPoint, Comparable<PointNode> {
  /// The first component (X) of the point.
  final int _x;

  /// The second component (Y) of the point.
  final int _y;

  /// The set of edges which start at this point.
  final EdgeNodeSet _startEdges;

  /// The set of edges which end at this point.
  final EdgeNodeSet _endEdges;

  /// The set of edges which pass through this node.
  final EdgeNodeSet _passEdges;

  /// Any additional data that this point should contain.
  Object _data;

  /// Creates a new point node.
  PointNode(int x, int y) {
    this._x = x;
    this._y = y;
    this._startEdges = new EdgeNodeSet();
    this._endEdges = new EdgeNodeSet();
    this._passEdges = new EdgeNodeSet();
    this._data = null;
  }

  /// Gets the first integer coordinate component.
  @Override
  int get x => this._x;

  /// Gets the second integer coordinate component.
  @Override
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
  bool get orphan => this._startEdges.isEmpty() && this._endEdges.isEmpty();

  /// Finds an edge that starts at this point and ends at the given point.
  EdgeNode findEdgeTo(IPoint end) => this.findEdgeTo(end.x, end.y);

  /// Finds an edge that starts at this point and ends at the given point.
  EdgeNode findEdgeTo(int x, int y) {
    for (EdgeNode edge in this._startEdges) {
      if (Point.equals(edge.endNode, x, y)) return edge;
    }
    return null;
  }

  /// Finds an edge that ends at this point and starts at the given point.
  EdgeNode findEdgeFrom(IPoint start) => this.findEdgeFrom(start.x, start.y);

  /// Finds an edge that ends at this point and starts at the given point.
  EdgeNode findEdgeFrom(int x, int y) {
    for (EdgeNode edge in this._endEdges) {
      if (Point.equals(edge.startNode, x, y)) return edge;
    }
    return null;
  }

  /// Finds an edge that starts or ends at this point and connects to the given point.
  EdgeNode findEdgeBetween(IPoint other) => this.findEdgeBetween(other.x, other.y);

  /// Finds an edge that starts or ends at this point and connects to the given point.
  EdgeNode findEdgeBetween(int x, int y) {
    EdgeNode edge = this.findEdgeTo(x, y);
    if (edge == null) edge = this.findEdgeFrom(x, y);
    return edge;
  }

  /// Adds an edge to this node and/or children nodes.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  @Override
  INode insertEdge(EdgeNode edge) {
    if (edge.startNode == this)
      this._startEdges.add(edge);
    else if (edge.endNode == this)
      this._endEdges.add(edge);
    else if (this.overlaps(edge)) this._passEdges.add(edge);
    return this;
  }

  /// Adds a point to this node.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  @Override
  INode insertPoint(PointNode point) {
    BranchNode branch = new BranchNode();
    branch.setLocation(this.xmin, this.ymin, this.width);
    int halfSize = this.width / 2;

    // Make a copy of this node and set is as a child of the new branch.
    Quadrant childQuad = branch.childQuad(this._x, this._y);
    this.setLocation(branch.childX(childQuad), branch.childY(childQuad), halfSize);
    branch.setChild(childQuad, this);

    // Copy lines to new siblings, keep any non-empty sibling.
    for (Quadrant quad in Quadrant.values) {
      if (quad != childQuad) {
        PassNode sibling = new PassNode();
        sibling.setLocation(branch.childX(quad), branch.childY(quad), halfSize);
        this.appendPassingEdges(sibling, this._startEdges);
        this.appendPassingEdges(sibling, this._endEdges);
        this.appendPassingEdges(sibling, this._passEdges);
        if (!sibling.passEdges.isEmpty()) branch.setChild(quad, sibling);
      }
    }

    // Remove any edges which no longer pass through this point.
    Iterator<EdgeNode> it = this._passEdges.iterator();
    while (it.hasNext()) {
      EdgeNode edge = it.next();
      if (this.overlaps(edge)) it.remove();
    }

    // Add the point to the new branch node, return new node.
    // This allows the branch to grow as needed.
    return branch.insertPoint(point);
  }

  /// This adds all the edges from the given set which pass through the given
  /// pass node to that node.
  void _appendPassingEdges(PassNode node, EdgeNodeSet edges) {
    for (EdgeNode edge in edges) {
      if (node.overlaps(edge)) node.passEdges.add(edge);
    }
  }

  /// Removes a edge from the tree at this node.
  /// [trimTree] indicates if the end points of the edge should be
  /// removed if no other edges begins or ends at that point.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  @Override
  INode removeEdge(EdgeNode edge, bool trimTree) {
    INode result = this;
    if (edge.startNode == this) {
      this._startEdges.remove(edge);
      if (trimTree && this.orphan) result = this.replacement;
    } else if (edge.endNode == this) {
      this._endEdges.remove(edge);
      if (trimTree && this.orphan) result = this.replacement;
    } else
      this._passEdges.remove(edge);
    return result;
  }

  /// This handles the first found intersecting edge.
  @Override
  IntersectionResult findFirstIntersection(IEdge edge, IEdgeHandler hndl) {
    if (this.overlaps(edge)) {
      IntersectionResult result;
      result = this.findFirstIntersection(this._startEdges, edge, hndl);
      if (result != null) return result;
      result = this.findFirstIntersection(this._endEdges, edge, hndl);
      if (result != null) return result;
      result = this.findFirstIntersection(this._passEdges, edge, hndl);
      if (result != null) return result;
    }
    return null;
  }

  /// This handles all the intersections.
  @Override
  bool findAllIntersections(IEdge edge, IEdgeHandler hndl, IntersectionSet intersections) {
    bool result = false;
    if (this.overlaps(edge)) {
      if (this.findAllIntersections(this._startEdges, edge, hndl, intersections)) result = true;
      if (this.findAllIntersections(this._endEdges, edge, hndl, intersections)) result = true;
      if (this.findAllIntersections(this._passEdges, edge, hndl, intersections)) result = true;
    }
    return result;
  }

  /// Handles each point node reachable from this node.
  @Override
  bool foreach(IPointHandler handle) {
    return handle.handle(this);
  }

  /// Handles each point node reachable from this node in the boundary.
  @Override
  bool foreach(IPointHandler handle, IBoundary bounds) {
    if (bounds.contains(this)) {
      return handle.handle(this);
    } else
      return true;
  }

  /// Handles each edge node reachable from this node.
  @Override
  bool foreach(IEdgeHandler handle) {
    // Since all nodes are checked only look at the start edges
    // so that edges are looked at only once.
    for (EdgeNode edge in this._startEdges) {
      if (!handle.handle(edge)) return false;
    }
    return true;
  }

  /// Handles each edge node reachable from this node in the boundary.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  // exists even partially in the region are collected.
  @Override
  bool foreach(IEdgeHandler handle, IBoundary bounds, bool exclusive) {
    if (this.overlaps(bounds)) {
      if (exclusive) {
        // Check all edges which start at this node to see if they end in the bounds.
        // No need to check passEdges nor endEdges because for all exclusive edges
        // all startEdges lists will be checked at some point.
        for (EdgeNode edge in this._startEdges) {
          if (bounds.contains(edge.x2, edge.y2)) {
            if (!handle.handle(edge)) return false;
          }
        }
      } else {
        for (EdgeNode edge in this._startEdges) {
          if (!handle.handle(edge)) return false;
        }
        for (EdgeNode edge in this._endEdges) {
          if (!handle.handle(edge)) return false;
        }
        for (EdgeNode edge in this._passEdges) {
          if (!handle.handle(edge)) return false;
        }
      }
    }
    return true;
  }

  /// Handles each node reachable from this node.
  @Override
  bool foreach(INodeHandler handle) {
    return handle.handle(this);
  }

  /// Handles each node reachable from this node in the boundary.
  @Override
  bool foreach(INodeHandler handle, IBoundary bounds) {
    return this.overlaps(bounds) && handle.handle(this);
  }

  /// Determines if the node has any point nodes inside it.
  /// Since this is a point node then it will always return true.
  @Override
  bool get hasPoints => true;

  /// Determines if the node has any edge nodes inside it.
  @Override
  bool get hasEdges => !(this._passEdges.isEmpty() || this._endEdges.isEmpty() || this._startEdges.isEmpty());

  /// Gets the first edge to the left of the given point.
  @Override
  void firstLeftEdge(FirstLeftEdgeArgs args) {
    this.firstLineLeft(this._startEdges, args);
    this.firstLineLeft(this._endEdges, args);
    this.firstLineLeft(this._passEdges, args);
  }

  /// Handles all the edges to the left of the given point.
  @Override
  bool foreachLeftEdge(IPoint point, IEdgeHandler handle) {
    if (!this.foreachLeftEdge(this._startEdges, point, handle)) return false;
    if (!this.foreachLeftEdge(this._endEdges, point, handle)) return false;
    if (!this.foreachLeftEdge(this._passEdges, point, handle)) return false;
    return true;
  }

  /// This finds the next point in the tree.
  PointNode nextPoint(IPointHandler handle) {
    if (this.parent == null)
      return null;
    else
      return this.parent.findNextPoint(this, null, handle);
  }

  /// This finds the next point within the given region in the tree.
  PointNode nextPoint(IBoundary boundary, IPointHandler handle) {
    if (this.parent == null)
      return null;
    else
      return this.parent.findNextPoint(this, boundary, handle);
  }

  /// This finds the previous point in the tree.
  PointNode previousPoint(IPointHandler handle) {
    if (this.parent == null)
      return null;
    else
      return this.parent.findPreviousPoint(this, null, handle);
  }

  /// This finds the previous point within the given region in the tree.
  PointNode previousPoint(IBoundary boundary, IPointHandler handle) {
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
    Edge queryEdge = new Edge(queryPoint.x(), queryPoint.y(), this.x(), this.y());

    EdgeNode rightMost = null;
    EdgeNode leftMost = null;
    EdgeNode center = null;

    // Check all edges which start at this node.
    for (EdgeNode edge in this.startEdges) {
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
    for (EdgeNode edge in this.endEdges) {
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
            Point.cross(rightMost.x2 - this.x, rightMost.y2 - this.y, queryPoint.x - this.x, queryPoint.y - this.y);
        double leftCross =
            Point.cross(queryPoint.x - this.x, queryPoint.y - this.y, leftMost.x2 - this.x, leftMost.y2 - this.y);
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
    if (this._passEdges.isEmpty()) return EmptyNode.instance;

    // Otherwise return a passing node with these passing edges.
    PassNode pass = new PassNode();
    pass.setLocation(this.xmin, this.ymin, this.width);
    pass.passEdges.addAll(this._passEdges);
    this._passEdges.clear();
    return pass;
  }

  /// Validates this node.
  @Override
  bool validate(StringBuffer sout, final IFormatter format, bool recursive) {
    bool result = true;
    if (!this.contains(this._x, this._y)) {
      sout.append("Error in ");
      this.toString(sout, format);
      sout.append(": The point is not contained by the node's region.\n");
      result = false;
    }

    for (EdgeNode edge in this._startEdges) {
      if (edge == null) {
        sout.append("Error in ");
        this.toString(sout, format);
        sout.append(": A null line was in the starting list.\n");
        result = false;
      } else {
        if (edge.startNode != this) {
          sout.append("Error in ");
          this.toString(sout, format);
          sout.append(": A line in the starting list, ");
          edge.toString(sout, "", false, true, format);
          sout.append(", doesn't start with this node.\n");
          result = false;
        }
        if (edge.endNode == this) {
          sout.append("Error in ");
          this.toString(sout, format);
          sout.append(": A line in the starting list, ");
          edge.toString(sout, "", false, true, format);
          sout.append(", also ends on this node.\n");
          result = false;
        }
        if (recursive) {
          if (!edge.validate(sout, format)) result = false;
        }
      }
    }

    for (EdgeNode edge in this._endEdges) {
      if (edge == null) {
        sout.append("Error in ");
        this.toString(sout, format);
        sout.append(": A null line was in the ending list.\n");
        result = false;
      } else {
        if (edge.endNode != this) {
          sout.append("Error in ");
          this.toString(sout, format);
          sout.append(": A line in the ending list, ");
          edge.toString(sout, "", false, true, format);
          sout.append(", doesn't end with this node.\n");
          result = false;
        }
        if (edge.startNode == this) {
          sout.append("Error in ");
          this.toString(sout, format);
          sout.append(": A line in the ending list, ");
          edge.toString(sout, "", false, true, format);
          sout.append(", also starts on this node.\n");
          result = false;
        }
      }
    }

    for (EdgeNode edge in this._passEdges) {
      if (edge == null) {
        sout.append("Error in ");
        this.toString(sout, format);
        sout.append(": A null line was in the passing list.\n");
        result = false;
      } else {
        if (!this.overlaps(edge)) {
          sout.append("Error in ");
          this.toString(sout, format);
          sout.append(": A line in the passing list, ");
          edge.toString(sout, "", false, true, format);
          sout.append(", doesn't pass through this node.\n");
          result = false;
        }
        if (edge.startNode == this) {
          sout.append("Error in ");
          this.toString(sout, format);
          sout.append(": A line in the passing list, ");
          edge.toString(sout, "", false, true, format);
          sout.append(", should be in the starting list.\n");
          result = false;
        }
        if (edge.endNode == this) {
          sout.append("Error in ");
          this.toString(sout, format);
          sout.append(": A line in the passing list, ");
          edge.toString(sout, "", false, true, format);
          sout.append(", should be in the ending list.\n");
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
  @Override
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
  @Override
  void toString(StringBuffer sout, String indent, bool children, bool contained, bool last, IFormatter format) {
    if (contained) {
      if (last)
        sout.append(StringParts.Last);
      else
        sout.append(StringParts.Child);
    }

    sout.append("PointNode: ");
    sout.append(this.point.toString(format));
    sout.append(", ");
    sout.append(this.boundary.toString(format));
    if (this._data != null) {
      sout.append(" ");
      sout.append(this._data.toString());
    }

    if (children) {
      String childIndent;
      if (contained && !last)
        childIndent = indent + StringParts.Bar;
      else
        childIndent = indent + StringParts.Space;

      final bool hasStart = (this._startEdges.size() > 0);
      final bool hasEnd = (this._endEdges.size() > 0);
      final bool hasPass = (this._passEdges.size() > 0);

      if (hasStart) {
        sout.append(StringParts.Sep);
        sout.append(indent);
        this._startEdges.toString(sout, childIndent, true, !(hasEnd || hasPass), format);
      }
      if (hasEnd) {
        sout.append(StringParts.Sep);
        sout.append(indent);
        this._endEdges.toString(sout, childIndent, true, !hasPass, format);
      }
      if (hasPass) {
        sout.append(StringParts.Sep);
        sout.append(indent);
        this._passEdges.toString(sout, childIndent, true, true, format);
      }
    }
  }
}
