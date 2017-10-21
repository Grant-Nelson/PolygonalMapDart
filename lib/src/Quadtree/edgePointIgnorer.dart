part of PolygonalMapDart.Quadtree;

/// A point handler for ignoring the start and end point of an edge.
class EdgePointIgnorer implements IPointHandler {
  /// The edge to ignore the points of.
  final IEdge _edge;

  /// Create a new edge point ignorer.
  /// The given [edge] is the edge to ignore the points of.
  EdgePointIgnorer(this._edge);

  /// Gets the edge to ignore the points of.
  IEdge get edge => _edge;

  /// Handles the point to check to ignore.
  /// Returns true to allow, false to ignore.
  bool handle(PointNode point) {
    return !(Point.equals(point, _edge.start) || Point.equals(point, _edge.end));
  }
}
