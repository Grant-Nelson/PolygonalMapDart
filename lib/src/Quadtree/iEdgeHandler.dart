part of PolygonalMap.Quadtree;

/// The edge node handler is used to process
/// or match edges with custom handlers inside for-each methods.
abstract class IEdgeHandler {
  /// Handles the given edge node.
  /// Return true to continue, false to stop.
  bool handle(EdgeNode edge);
}
