part of PolygonalMapDart.Quadtree;

/// An edge handler to ignore a neighboring edge to the given edge.
class NeighborEdgeIgnorer implements IEdgeHandler {
  /// The edge to ignore and ignore the neighbors of.
  final IEdge _edge;

  /// Creates a new neighbor edge ignorer.
  /// The given [edge] is the edge to ignore and ignore the neighbors of.
  NeighborEdgeIgnorer(IEdge this._edge);

  /// Gets the edge to ignore and ignore the neighbors of.
  IEdge get edge => this._edge;

  /// Handles an edge to check if it should be ignored.
  bool handle(EdgeNode edge) => !(Point.equalPoints(edge.start, this._edge.start) ||
      Point.equalPoints(edge.start, this._edge.end) ||
      Point.equalPoints(edge.end, this._edge.start) ||
      Point.equalPoints(edge.end, this._edge.end));
}
