part of PolygonalMapDart.Quadtree;

/// The side of the edge that a point can be.
/// The side is determined by looking down the edge
/// from the start point towards the end point.
enum Side {
  /// The point is to the left of the edge.
  Left,

  /// The point is to the right of the edge.
  Right,

  /// The point is on the edge.
  Inside
}
