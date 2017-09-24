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
  int region(int x, int y);

  /// Gets the boundary region the given point was in.
  int region(IPoint point);

  /// Checks if the given point is completely contained within this boundary.
  bool contains(int x, int y);

  /// Checks if the given point is completely contained within this boundary.
  bool contains(IPoint point);

  /// Checks if the given edge is completely contained within this boundary.
  bool contains(IEdge edge);

  /// Checks if the given boundary is completely contains by this boundary.
  bool contains(IBoundary boundary);

  /// Checks if the given edge overlaps this boundary.
  bool overlaps(IEdge edge);

  /// Checks if the given boundary overlaps this boundary.
  bool overlaps(IBoundary boundary);

  /// Gets the distance squared from this boundary to the given point.
  double distance2(int x, int y);

  /// Gets the distance squared from this boundary to the given point.
  double distance2(IPoint point);
}
