part of PolygonalMapDart.Quadtree;

/// The interface for boundary types.
abstract class IBoundary {
  /// Gets the minimum x component.
  int get xmin;

  /// Gets the minimum y component.
  int get ymin;

  /// Gets the maximum x component.
  int get xmax;

  /// Gets the maximum y component.
  int get ymax;

  /// Gets the width of boundary.
  int get width;

  /// Gets the height of boundary.
  int get height;

  /// Gets the boundary region the given point was in.
  int region(IPoint point);

  /// Checks if the given point is completely contained within this boundary.
  bool containsPoint(IPoint point);

  /// Checks if the given edge is completely contained within this boundary.
  bool containsEdge(IEdge edge);

  /// Checks if the given boundary is completely contains by this boundary.
  bool containsBoundary(IBoundary boundary);

  /// Checks if the given edge overlaps this boundary.
  bool overlapsEdge(IEdge edge);

  /// Checks if the given boundary overlaps this boundary.
  bool overlapsBoundary(IBoundary boundary);

  /// Gets the distance squared from this boundary to the given point.
  double distance2(IPoint point);
}
