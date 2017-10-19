part of PolygonalMapDart.Quadtree;

/// This is the base node for all non-empty nodes.
abstract class BaseNode implements INode, IBoundary {
  /// The minimum X location of this node.
  int _xmin;

  /// The minimum Y location of this node.
  int _ymin;

  /// The width and height of this node.
  int _size;

  /// The parent of this node.
  BranchNode _parent;

  /// Creates a new base node.
  BaseNode._() {
    _xmin = 0;
    _ymin = 0;
    _size = 1;
    _parent = null;
  }

  /// Adds an edge to this node and/or children nodes.
  /// Returns the node that should be the new root of the subtree
  /// that was defined by this node.
  INode insertEdge(EdgeNode edge);

  /// Adds a point to this node.
  /// Returns the node that should be the new root of the subtree
  /// that was defined by this node.
  INode insertPoint(PointNode point);

  /// Removes a edge from the tree at this node.
  /// [trimTree] indicates if the end points of the edge should be
  /// removed if no other edges begins or ends at that point.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  INode removeEdge(EdgeNode edge, bool trimTree);

  /// The parent node to this node.
  BranchNode get parent => _parent;
  set parent(BranchNode parent) => _parent = parent;

  /// Determines the depth of this node in the tree.
  /// Returns the depth of this node in the tree,
  /// if it has no parents then the depth is zero.
  int get depth {
    int depth = 0;
    BranchNode parent = _parent;
    while (parent != null) {
      parent = parent.parent;
      ++depth;
    }
    return depth;
  }

  /// Determines the root of this tree.
  BaseNode get root {
    BaseNode cur = this;
    while (true) {
      BaseNode parent = cur.parent;
      if (parent == null) return cur;
      cur = parent;
    }
  }

  /// Determines the common ancestor node between this node and the other node.
  /// Returns the common ancestor or null if none exists.
  BranchNode commonAncestor(BaseNode other) {
    int depth1 = depth;
    int depth2 = other.depth;
    BranchNode parent1 = _parent;
    BranchNode parent2 = other._parent;

    // Get the parents to the same depth.
    while (depth1 > depth2) {
      if (parent1 == null) return null;
      parent1 = parent1.parent;
      --depth1;
    }
    while (depth2 > depth1) {
      if (parent2 == null) return null;
      parent2 = parent2.parent;
      --depth2;
    }

    // Keep going up tree until the parents are the same.
    while (parent1 != parent2) {
      if (parent1 == null) return null;
      if (parent2 == null) return null;
      parent1 = parent1.parent;
      parent2 = parent2.parent;
    }

    // Return the common ancestor.
    return parent1;
  }

  /// Gets creates a boundary for this node.
  Boundary get boundary =>
      new Boundary(_xmin, _ymin, xmax, ymax);

  /// Sets the location of this node.
  void setLocation(int xmin, int ymin, int size) {
    assert(size > 0);
    _xmin = xmin;
    _ymin = ymin;
    _size = size;
  }

  /// Gets the minimum X location of this node.
  int get xmin => _xmin;

  /// Gets the minimum Y location of this node.
  int get ymin => _ymin;

  /// Gets the maximum X location of this node.
  int get xmax => _xmin + _size - 1;

  /// Gets the maximum Y location of this node.
  int get ymax => _ymin + _size - 1;

  /// Gets the width of boundary.
  int get width => _size;

  /// Gets the height of boundary.
  int get height => _size;

  /// Gets the boundary region the given point was in.
  int region(IPoint point) => boundary.region(point);

  /// Checks if the given point is completely contained within this boundary.
  /// Returns true if the point is fully contained, false otherwise.
  bool containsPoint(IPoint point) => boundary.containsPoint(point);

  /// Checks if the given edge is completely contained within this boundary.
  /// Returns true if the edge is fully contained, false otherwise.
  bool containsEdge(IEdge edge) => boundary.containsEdge(edge);

  /// Checks if the given boundary is completely contains by this boundary.
  /// Returns true if the boundary is fully contained, false otherwise.
  bool containsBoundary(IBoundary boundary) => boundary.containsBoundary(boundary);

  /// Checks if the given edge overlaps this boundary.
  /// Returns true if the edge is overlaps, false otherwise.
  bool overlapsEdge(IEdge edge) => boundary.overlapsEdge(edge);

  /// Checks if the given boundary overlaps this boundary.
  /// Returns true if the given boundary overlaps this boundary,
  /// false otherwise.
  bool overlapsBoundary(IBoundary boundary) => boundary.overlapsBoundary(boundary);

  /// Gets the distance squared from this boundary to the given point.
  /// Returns the distance squared from this boundary to the given point.
  double distance2(IPoint point) => boundary.distance2(point);

  /// This gets the first edge to the left of the given point.
  /// The [args] are an argument class used to store all the arguments and
  /// results for running this methods.
  void _firstLineLeft(Set<EdgeNode> edgeSet, FirstLeftEdgeArgs args) {
    edgeSet.map(args.update);
  }

  /// This handles all the edges in the given set to the left of the given point.
  bool _foreachLeftEdge(
      Set<EdgeNode> edgeSet, IPoint point, IEdgeHandler handle) {
    for (EdgeNode edge in edgeSet) {
      if (edge.y1 > point.y) {
        if (edge.y2 > point.y) continue;
      } else if (edge.y1 < point.y) {
        if (edge.y2 < point.y) continue;
      }

      if ((edge.x1 > point.x) && (edge.x2 > point.x)) continue;

      double x = (point.y - edge.y2) * edge.dx / edge.dy + edge.x2;
      if (x > point.x) continue;
      if (!handle.handle(edge)) return false;
    }
    return true;
  }

  /// This handles the first found intersecting edge in the given edge set.
  IntersectionResult _findFirstIntersection(
      Set<EdgeNode> edgeSet, IEdge edge, IEdgeHandler hndl) {
    for (EdgeNode other in edgeSet) {
      if ((hndl == null) || hndl.handle(other)) {
        IntersectionResult inter = Edge.intersect(edge, other);
        if (inter.intersects) {
          return inter;
        }
      }
    }
    return null;
  }

  /// This handles all the intersections in the given edge set.
  bool _findAllIntersections(Set<EdgeNode> edgeSet, IEdge edge, IEdgeHandler hndl,
      IntersectionSet intersections) {
    bool result = false;
    for (EdgeNode other in edgeSet) {
      if ((hndl == null) || hndl.handle(other)) {
        if (!intersections.constainsB(other)) {
          IntersectionResult inter = Edge.intersect(edge, other);
          if (inter.intersects) {
            intersections.results.add(inter);
            result = true;
          }
        }
      }
    }
    return result;
  }

  /// Gets the string for this node.
  String toString() {
    StringBuffer sout = new StringBuffer();
    toBuffer(sout);
    return sout.toString();
  }
}
