part of PolygonalMapDart.Quadtree;

/// The types of intersections between two lines.
class IntersectionType {
  /// The intersect between two the two edges could not be determined.
  static const int None = 0;

  /// The two edges are the same.
  static const int Same = 1;

  /// The two edges are the opposite.
  static const int Opposite = 2;

  /// The two lines defined with the given edges are parallel.
  static const int Parallel = 4;

  /// The two lines defined with the given edges share multiple points.
  static const int Coincide = 5;

  /// The two lines coincide but the edges don't touch.
  static const int Collinear = 6;

  /// The two lines defined with the given edges share a single a point.
  static const int Point = 7;

  // Keep this class from being constructed.
  IntersectionType._();
}
