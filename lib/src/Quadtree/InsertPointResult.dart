part of PolygonalMapDart.Quadtree;

/// The result from a point insertion into the tree.
class InsertPointResult {
  /// The inserted point.
  final PointNode point;

  /// True if the point existed, false if the point is new.
  final bool existed;

  /// Creates a new insert point result.
  InsertPointResult(this.point, this.existed);
}
