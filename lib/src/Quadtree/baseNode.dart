part of PolygonalMap.Quadtree;

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
    this._xmin = 0;
    this._ymin = 0;
    this._size = 1;
    this._parent = null;
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

  /// This gets the parent node to this node.
  BranchNode get parent => this._parent;

  /// This sets the parent node to this node.
  void set parent(BranchNode parent) {
    this._parent = parent;
  }

  /// Determines the depth of this node in the tree.
  /// Returns the depth of this node in the tree,
  /// if it has no parents then the depth is zero.
  int get depth {
    int depth = 0;
    BranchNode parent = this._parent;
    while (parent != null) {
      parent = parent.parent();
      ++depth;
    }
    return depth;
  }

  /// Determines the root of this tree.
  BaseNode get root {
    BaseNode cur = this;
    while (true) {
      BaseNode parent = cur.parent();
      if (parent == null) return cur;
      cur = parent;
    }
  }

  /// Determines the common ancestor node between this node and the other node.
  /// Returns the common ancestor or null if none exists.
  BranchNode commonAncestor(BaseNode other) {
    int depth1 = this.depth();
    int depth2 = other.depth();
    BranchNode parent1 = this._parent;
    BranchNode parent2 = other._parent;

    // Get the parents to the same depth.
    while (depth1 > depth2) {
      if (parent1 == null) return null;
      parent1 = parent1.parent();
      --depth1;
    }
    while (depth2 > depth1) {
      if (parent2 == null) return null;
      parent2 = parent2.parent();
      --depth2;
    }

    // Keep going up tree until the parents are the same.
    while (parent1 != parent2) {
      if (parent1 == null) return null;
      if (parent2 == null) return null;
      parent1 = parent1.parent();
      parent2 = parent2.parent();
    }

    // Return the common ancestor.
    return parent1;
  }

  /// Gets creates a boundary for this node.
  Boundary get boundary => new Boundary(this._xmin, this._ymin, this.xmax(), this.ymax());

  /// Sets the location of this node.
  void set location(int xmin, int ymin, int size) {
    assert(size > 0);
    this._xmin = xmin;
    this._ymin = ymin;
    this._size = size;
  }

  /// Gets the minimum X location of this node.
  @Override
  int get xmin => this._xmin;

  /// Gets the minimum Y location of this node.
  @Override
  int get ymin => this._ymin;

  /// Gets the maximum X location of this node.
  @Override
  int get xmax => this._xmin + this._size - 1;

  /// Gets the maximum Y location of this node.
  @Override
  int get ymax => this._ymin + this._size - 1;

  /// Gets the width of boundary.
  @Override
  int get width => this._size;

  /// Gets the height of boundary.
  @Override
  int get height => this._size;

  /// Gets the boundary region the given point was in.
  @Override
  int region(int x, int y) => this.boundary().region(x, y);

  /// Gets the boundary region the given point was in.
  @Override
  int region(IPoint point) => this.boundary().region(point);

  /// Checks if the given point is completely contained within this boundary.
  /// Returns true if the point is fully contained, false otherwise.
  @Override
  bool contains(int x, int y) => this.boundary().contains(x, y);

  /// Checks if the given point is completely contained within this boundary.
  /// Returns true if the point is fully contained, false otherwise.
  @Override
  bool contains(IPoint point) => this.boundary().contains(point);

  /// Checks if the given edge is completely contained within this boundary.
  /// Returns true if the edge is fully contained, false otherwise.
  @Override
  bool contains(IEdge edge) => this.boundary().contains(edge);

  /// Checks if the given boundary is completely contains by this boundary.
  /// Returns true if the boundary is fully contained, false otherwise.
  @Override
  bool contains(IBoundary boundary) => this.boundary().contains(boundary);

  /// Checks if the given edge overlaps this boundary.
  /// Returns true if the edge is overlaps, false otherwise.
  @Override
  bool overlaps(IEdge edge) => this.boundary().overlaps(edge);

  /// Checks if the given boundary overlaps this boundary.
  /// Returns true if the given boundary overlaps this boundary,
  /// false otherwise.
  @Override
  bool overlaps(IBoundary boundary) => this.boundary().overlaps(boundary);

  /// Gets the distance squared from this boundary to the given point.
  /// Returns the distance squared from this boundary to the given point.
  @Override
  double distance2(int x, int y) => this.boundary().distance2(x, y);

  /// Gets the distance squared from this boundary to the given point.
  /// Returns the distance squared from this boundary to the given point.
  @Override
  double distance2(IPoint point) => this.boundary().distance2(point);

  /// This gets the first edge to the left of the given point.
  /// The [args] are an argument class used to store all the arguments and
  /// results for running this methods.
  void _firstLineLeft(EdgeNodeSet edgeSet, FirstLeftEdgeArgs args) {
    for (EdgeNode edge in edgeSet) {
      args.update(edge);
    }
  }

  /// This handles all the edges in the given set to the left of the given point.
  bool _foreachLeftEdge(EdgeNodeSet edgeSet, IPoint point, IEdgeHandler handle) {
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
  IntersectionResult _findFirstIntersection(EdgeNodeSet edgeSet, IEdge edge, IEdgeHandler hndl) {
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
  bool _findAllIntersections(EdgeNodeSet edgeSet, IEdge edge, IEdgeHandler hndl, IntersectionSet intersections) {
    bool result = false;
    for (EdgeNode other in edgeSet) {
      if ((hndl == null) || hndl.handle(other)) {
        if (!intersections.constainsB(other)) {
          IntersectionResult inter = Edge.intersect(edge, other);
          if (inter.intersects) {
            intersections.add(inter);
            result = true;
          }
        }
      }
    }
    return result;
  }

  /// Formats just this node into a string.
  @Override
  void toString(StringBuffer sout, {IFormatter format: null}) {
    this.toString(sout, "", false, false, true, format);
  }
}
