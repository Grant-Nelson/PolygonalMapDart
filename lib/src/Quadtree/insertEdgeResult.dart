part of PolygonalMap.Quadtree;

/// The result from a edge insertion into the tree.
class InsertEdgeResult {
  /// The inserted edge.
  final EdgeNode edge;

  /// True if the edge existed, false if the edge is new.
  final bool existed;

  /// Creates a new insert edge result.
  InsertEdgeResult(EdgeNode this.edge, bool this.existed);
}
