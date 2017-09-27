part of PolygonalMapDart.Quadtree;

/// The side of the edge that a point can be.
/// The side is determined by looking down the edge
/// from the start point towards the end point.
class Side {
  /// The point is to the left of the edge.
  static const int Left = 0;

  /// The point is to the right of the edge.
  static const int Right = 1;

  /// The point is on the edge.
  static const int Inside = 2;

  // Keep this class from being constructed.
  Side._();
}
