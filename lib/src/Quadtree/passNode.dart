part of PolygonalMapDart.Quadtree;

/// The pass node is a leaf node which has
/// at least one line passing over the node.
class PassNode extends BaseNode {
  /// The set of edges which pass through this node.
  final EdgeNodeSet _passEdges;

  /// Creates the pass node.
  PassNode() {
    this._passEdges = new EdgeNodeSet();
  }

  /// Gets the set of edges which pass through this node.
  EdgeNodeSet get passEdges => this._passEdges;

  /// Adds an edge to this node and/or children nodes.
  /// Returns the node that should be the new root of the subtree
  /// that was defined by this node.
  @Override
  INode insertEdge(EdgeNode edge) {
    if (this.overlaps(edge)) this._passEdges.add(edge);
    return this;
  }

  /// Adds a point to this node.
  /// Returns the node that should be the new root of the subtree
  @Override
  INode insertPoint(PointNode point) {
    point.setLocation(this.xmin, this.ymin, this.width);
    point.passEdges.addAll(this._passEdges);
    return point;
  }

  /// Removes a edge from the tree at this node.
  /// [trimTree] indicates if the end points of the edge should be
  /// removed if no other edges begins or ends at that point.
  /// Return the node that should be the new root of the subtree that was
  /// defined by this node.
  @Override
  INode removeEdge(EdgeNode edge, bool trimTree) {
    if (this._passEdges.remove(edge)) {
      // If this node no longer has any edges replace this node with an
      // empty node.
      if (this._passEdges.isEmpty) {
        return EmptyNode.instance;
      }
    }
    return this;
  }

  /// This handles the first found intersecting edge.
  @Override
  IntersectionResult findFirstIntersection(IEdge edge, IEdgeHandler hndl) {
    if (this.overlaps(edge)) {
      return this.findFirstIntersection(this._passEdges, edge, hndl);
    }
    return null;
  }

  /// This handles all the intersections.
  @Override
  bool findAllIntersections(IEdge edge, IEdgeHandler hndl, IntersectionSet intersections) {
    if (this.overlaps(edge)) {
      return this.findAllIntersections(this._passEdges, edge, hndl, intersections);
    }
    return false;
  }

  /// Handles each point node reachable from this node.
  @Override
  bool foreach(IPointHandler handle) => true;

  /// Handles each point node reachable from this node in the boundary.
  @Override
  bool foreach(IPointHandler handle, IBoundary bounds) => true;

  /// Handles each edge node reachable from this node.
  ///
  /// Since all the nodes will be checked only the starting edges on
  /// point nodes are looked at so that each edge is only checked once.
  @Override
  bool foreach(IEdgeHandler handle) => true;

  /// Handles each edge node reachable from this node in the boundary.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  /// exists even partially in the region are collected.
  @Override
  bool foreach(IEdgeHandler handle, IBoundary bounds, bool exclusive) {
    if (!exclusive) {
      if (this.overlaps(bounds)) {
        for (EdgeNode edge in this._passEdges) {
          if (!handle.handle(edge)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  /// Handles each node reachable from this node.
  @Override
  bool foreach(INodeHandler handle) => handle.handle(this);

  /// Handles each node reachable from this node in the boundary.
  @Override
  bool foreach(INodeHandler handle, IBoundary bounds) => this.overlaps(bounds) && handle.handle(this);

  /// Determines if the node has any point nodes inside it. This node will
  /// never contain a point and will always return false.
  @Override
  bool get hasPoints => false;

  /// Determines if the node has any edge nodes inside it. Since a pass node
  /// must have at least one edge in it this will always return true.
  @Override
  bool get hasEdges => true;

  /// Gets the first edge to the left of the given point.
  @Override
  void firstLeftEdge(FirstLeftEdgeArgs args) {
    this.firstLineLeft(this._passEdges, args);
  }

  /// Handles all the edges to the left of the given point.
  @Override
  bool foreachLeftEdge(IPoint point, IEdgeHandler handle) => this.foreachLeftEdge(this._passEdges, point, handle);

  /// Validates this node.
  /// Set [recursive] to true to validate all children nodes too, false otherwise.
  @Override
  bool validate(StringBuffer sout, IFormatter format, bool recursive) {
    bool result = true;
    for (EdgeNode edge in this._passEdges) {
      if (!this.overlaps(edge)) {
        sout.append("Error in ");
        this.toString(sout, format);
        sout.append(": An edge in the passing list, ");
        edge.toString(sout, format);
        sout.append(", doesn't pass through this node.\n");
        result = false;
      }
    }
    return result;
  }

  /// Formats the nodes into a string.
  /// [children] indicates any child should also be stringified.
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

    sout.append("PassNode: ");
    sout.append(this.boundary().toString(format));

    if (children) {
      if (this._passEdges.size() > 0) {
        sout.append(StringParts.Sep);
        sout.append(indent);
      }
      String childIndent;
      if (contained && !last)
        childIndent = indent + StringParts.Bar;
      else
        childIndent = indent + StringParts.Space;
      this._passEdges.toString(sout, childIndent, true, true, format);
    }
  }
}
