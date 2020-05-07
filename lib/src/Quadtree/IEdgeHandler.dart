part of PolygonalMapDart.Quadtree;

/// The edge node handler is used to process
/// or match edges with custom handlers inside for-each methods.
abstract class IEdgeHandler {
  /// Handles the given edge node.
  /// Return true to continue, false to stop.
  bool handle(IEdge edge);
}

/// The method type for handling edge nodes.
typedef bool EdgeHandler(IEdge value);

/// Handler for calling a given function pointer for each edge.
class EdgeMethodHandler implements IEdgeHandler {
  /// The handle to call for each edge.
  EdgeHandler _hndl;

  /// Creates a new edge handler.
  EdgeMethodHandler(this._hndl);

  /// Handles the given edge.
  bool handle(IEdge edge) {
    return _hndl(edge);
  }
}
