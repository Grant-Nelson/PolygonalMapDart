part of PolygonalMapDart.Quadtree;

/// Indicates where an intersection occurs on an edge.
class IntersectionLocation {
  /// Intersection type not set, not determined, or not determinable.
  static const int None = 0;

  /// Intersection occurs in edge's line before the edge's start point.
  static const int BeforeStart = 1;

  /// Intersection occurs within edge.
  static const int InMiddle = 2;

  /// Intersection occurs in edge's line past the edge's end point.
  static const int PastEnd = 3;

  /// Intersection occurs at the edge's start point.
  static const int AtStart = 4;

  /// Intersection occurs at the edge's end point.
  static const int AtEnd = 5;

  // Keep this class from being constructed.
  IntersectionLocation._();
}
