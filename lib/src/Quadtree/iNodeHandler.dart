part of PolygonalMapDart.Quadtree;

/// The node handler is used to process
/// or match points with custom handlers inside for each methods.
abstract class INodeHandler {
  /// Handles the given node.
  /// The [node] to handle.
  /// Returns true to continue or accept, false to stop or reject.
  bool handle(INode node);
}
