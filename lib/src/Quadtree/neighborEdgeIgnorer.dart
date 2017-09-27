part of PolygonalMapDart.Quadtree;

/// An edge handler to ignore a neighboring edge to the given edge.
class NeighborEdgeIgnorer implements IEdgeHandler {
  /// The edge to ignore and ignore the neighbors of.
  final IEdge _edge;

  /// Creates a new neighbor edge ignorer.
  /// The given [edge] is the edge to ignore and ignore the neighbors of.
  NeighborEdgeIgnorer(IEdge edge) {
    this._edge = edge;
  }

  /// Gets the edge to ignore and ignore the neighbors of.
  IEdge get edge => this._edge;

  /// Handles an edge to check if it should be ignored.

  bool handle(EdgeNode edge) => !(Point.equals(edge.start, this._edge.start) ||
      Point.equals(edge.start, this._edge.end) ||
      Point.equals(edge.end, this._edge.start) ||
      Point.equals(edge.end, this._edge.end));
}
