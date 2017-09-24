part of PolygonalMap.Quadtree;

/// The interface for all nodes in a quad-tree.
abstract class INode {
  /// Handles each point node reachable from this node.
  /// Returns true if all points were run, false if stopped.
  bool foreach(IPointHandler handle, [IBoundary bounds = null]);

  /// Handles each edge node reachable from this node.
  /// Returns true if all edges were run, false if stopped.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  /// exists even partially in the region are collected.
  bool foreach(IEdgeHandler handle, [IBoundary bounds = null, bool exclusive = false]);

  /// Handles each node reachable from this node.
  /// Returns true if all nodes were run, false if stopped.
  bool foreach(INodeHandler handle, [IBoundary bounds = null]);

  /// Determines if the node has any point nodes inside it.
  bool get hasPoints;

  /// Determines if the node has any edge nodes inside it.
  bool get hasEdges;

  /// Gets the first edge to the left of the given point.
  /// The [args] is used to store all the input arguments and
  /// results for running this methods.
  void firstLeftEdge(FirstLeftEdgeArgs args);

  /// Handles all the edges to the left of the given point.
  /// The [query] is the point to find the left edges from.
  /// Returns true if all the edges were processed, false if the handle stopped early.
  bool foreachLeftEdge(IPoint query, IEdgeHandler hndl);

  /// This handles the first found intersecting edge.
  /// The [edge] to look for intersections with.
  /// The [hndl] is the handler to match valid edges with.
  /// Returns the first found intersection.
  IntersectionResult findFirstIntersection(IEdge edge, IEdgeHandler hndl);

  /// This handles all the intersections.
  /// The [edge] to look for intersections with.
  /// The [hndl] is the handler to match valid edges with.
  /// The set of [intersections] to add to.
  /// Returns true if a new intersection was found.
  bool findAllIntersections(IEdge edge, IEdgeHandler hndl, IntersectionSet intersections);

  /// Validates this node.
  /// The [format] is used for printing, null to use default.
  /// Set [recursive] true to validate all children nodes too, false otherwise.
  /// Returns true if valid, false if invalid.
  bool validate(StringBuffer sout, IFormatter format, bool recursive);

  /// Formats just this node into a string.
  /// The [format] is used for printing, null to use default.
  /// [children] indicates any child should also be stringified.
  /// [contained] indicates this node is part of another node.
  /// [last] indicates this is the last node of the parent.
  void toString(StringBuffer sout,
      {String indent: "", bool children: true, bool contained: false, bool last: false, IFormatter format: null});
}
