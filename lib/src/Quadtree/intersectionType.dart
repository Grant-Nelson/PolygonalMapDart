part of PolygonalMap.Quadtree;

/// The types of intersections between two lines.
enum IntersectionType {
  /// The two edges are the same.
  Same,

  /// The two edges are the opposite.
  Opposite,

  /// The two lines defined with the given edges are parallel.
  Parallel,

  /// The two lines defined with the given edges share multiple points.
  Coincide,

  /// The two lines coincide but the edges don't touch.
  Collinear,

  /// The two lines defined with the given edges share a single a point.
  Point,

  /// The intersect between two the two edges could not be determined.
  None
}
