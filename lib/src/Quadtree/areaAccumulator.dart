part of PolygonalMapDart.Quadtree;

/// An edge handler which can be used to accumulate a shapes area.
class AreaAccumulator implements IEdgeHandler {
  /// The currently accumulated area.
  double _area;

  /// Create a new area accumulator.
  AreaAccumulator() {
    _area = 0.0;
  }

  /// This gets the signed area accumulated.
  /// A positive area generally wraps counter-clockwise,
  /// a negative area generally wraps clockwise.
  double get signedArea => _area;

  /// This returns the unsigned area accumulated.
  double get area => (_area < 0.0) ? -_area : _area;

  /// Indicates if the shape  if accumulated area is counter clockwise,
  /// Returns true if counter clockwise, false if clockwise.
  bool get ccw => _area > 0.0;

  /// Adds a new edge of the shape to the accumulated area.
  /// Always returns true.
  bool handle(IEdge edge) {
    _area += (edge.x1.toDouble() * edge.y2.toDouble() -
            edge.x2.toDouble() * edge.y1.toDouble()) *
        0.5;
    return true;
  }
}
