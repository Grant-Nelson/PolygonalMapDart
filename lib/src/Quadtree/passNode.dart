part of PolygonalMapDart.Quadtree;

/// The pass node is a leaf node which has
/// at least one line passing over the node.
class PassNode extends BaseNode {
  /// The set of edges which pass through this node.
  Set<EdgeNode> _passEdges;

  /// Creates the pass node.
  PassNode() : super._() {
    _passEdges = new Set<EdgeNode>();
  }

  /// Gets the set of edges which pass through this node.
  Set<EdgeNode> get passEdges => _passEdges;

  /// Adds an edge to this node and/or children nodes.
  /// Returns the node that should be the new root of the subtree
  /// that was defined by this node.
  INode insertEdge(EdgeNode edge) {
    if (overlapsEdge(edge)) _passEdges.add(edge);
    return this;
  }

  /// Adds a point to this node.
  /// Returns the node that should be the new root of the subtree
  INode insertPoint(PointNode point) {
    point.setLocation(xmin, ymin, width);
    point.passEdges.addAll(_passEdges);
    return point;
  }

  /// Removes a edge from the tree at this node.
  /// [trimTree] indicates if the end points of the edge should be
  /// removed if no other edges begins or ends at that point.
  /// Return the node that should be the new root of the subtree that was
  /// defined by this node.
  INode removeEdge(EdgeNode edge, bool trimTree) {
    if (_passEdges.remove(edge)) {
      // If this node no longer has any edges replace this node with an
      // empty node.
      if (_passEdges.isEmpty) {
        return EmptyNode.instance;
      }
    }
    return this;
  }

  /// This handles the first found intersecting edge.
  IntersectionResult findFirstIntersection(IEdge edge, IEdgeHandler hndl) {
    if (overlapsEdge(edge)) {
      return _findFirstIntersection(_passEdges, edge, hndl);
    }
    return null;
  }

  /// This handles all the intersections.
  bool findAllIntersections(IEdge edge, IEdgeHandler hndl, IntersectionSet intersections) {
    if (overlapsEdge(edge)) {
      return _findAllIntersections(_passEdges, edge, hndl, intersections);
    }
    return false;
  }

  /// Handles each point node reachable from this node in the boundary.
  bool foreachPoint(IPointHandler handle, [IBoundary bounds = null]) => true;

  /// Handles each edge node reachable from this node in the boundary.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  /// exists even partially in the region are collected.
  bool foreachEdge(IEdgeHandler handle, [IBoundary bounds = null, bool exclusive = false]) {
    if (!exclusive) {
      if (overlapsBoundary(bounds)) {
        for (EdgeNode edge in _passEdges) {
          if (!handle.handle(edge)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  /// Handles each node reachable from this node in the boundary.
  bool foreachNode(INodeHandler handle, [IBoundary bounds = null]) {
    if (bounds != null) {
      return overlapsBoundary(bounds) && handle.handle(this);
    } else {
      return handle.handle(this);
    }
  }

  /// Determines if the node has any point nodes inside it. This node will
  /// never contain a point and will always return false.
  bool get hasPoints => false;

  /// Determines if the node has any edge nodes inside it. Since a pass node
  /// must have at least one edge in it this will always return true.
  bool get hasEdges => true;

  /// Gets the first edge to the left of the given point.
  void firstLeftEdge(FirstLeftEdgeArgs args) => _firstLineLeft(_passEdges, args);

  /// Handles all the edges to the left of the given point.
  bool foreachLeftEdge(IPoint point, IEdgeHandler handle) => _foreachLeftEdge(_passEdges, point, handle);

  /// Validates this node.
  /// Set [recursive] to true to validate all children nodes too, false otherwise.
  bool validate(StringBuffer sout, IFormatter format, bool recursive) {
    bool result = true;
    for (EdgeNode edge in _passEdges) {
      if (!overlapsEdge(edge)) {
        sout.write("Error in ");
        toBuffer(sout, format: format);
        sout.write(": An edge in the passing list, ");
        edge.toBuffer(sout, format: format);
        sout.write(", doesn't pass through this node.\n");
        result = false;
      }
    }
    return result;
  }

  /// Formats the nodes into a string.
  /// [children] indicates any child should also be stringified.
  /// [contained] indicates this node is part of another node.
  /// [last] indicates this is the last node of the parent.
  void toBuffer(StringBuffer sout,
      {String indent = "", bool children = false, bool contained = false, bool last = true, IFormatter format = null}) {
    if (contained) {
      if (last)
        sout.write(StringParts.Last);
      else
        sout.write(StringParts.Child);
    }

    sout.write("PassNode: ");
    sout.write(boundary.toString(format: format));

    if (children) {
      if (_passEdges.length > 0) {
        sout.write(StringParts.Sep);
        sout.write(indent);
      }
      String childIndent;
      if (contained && !last)
        childIndent = indent + StringParts.Bar;
      else
        childIndent = indent + StringParts.Space;
      Edge.edgeNodesToBuffer(_passEdges, sout, indent: childIndent, contained: true, last: true, format: format);
    }
  }
}
