part of PolygonalMapDart.Quadtree;

/// The node handler is used to process
/// or match points with custom handlers inside for each methods.
abstract class INodeHandler {
  /// Handles the given node.
  /// The [node] to handle.
  /// Returns true to continue or accept, false to stop or reject.
  bool handle(INode node);
}

/// The method type for handling nodes.
typedef bool NodeHandler(PointNode);

/// Handler for calling a given function pointer for each node.
class NodeMethodHandler implements IPointHandler {
  /// The handle to call for each node.
  NodeHandler _hndl;

  /// Creates a new node handler.
  NodeMethodHandler(this._hndl);

  /// Handles the given node.
  bool handle(INode node) {
    return _hndl(node);
  }
}
