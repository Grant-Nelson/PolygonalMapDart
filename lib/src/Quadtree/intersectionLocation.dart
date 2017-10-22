part of PolygonalMapDart.Quadtree;

/// Indicates where an intersection occurs on an edge.
enum IntersectionLocation {
  /// Intersection type not set, not determined, or not determinable.
  None,

  /// Intersection occurs in edge's line before the edge's start point.
  BeforeStart,

  /// Intersection occurs within edge.
  InMiddle,

  /// Intersection occurs in edge's line past the edge's end point.
  PastEnd,

  /// Intersection occurs at the edge's start point.
  AtStart,

  /// Intersection occurs at the edge's end point.
  AtEnd
}
