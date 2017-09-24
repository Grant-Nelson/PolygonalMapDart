part of PolygonalMap.Quadtree;

/// The point handler is used to process
/// or match points with custom handlers inside for-each methods.
abstract class IPointHandler {
  /// Handles the given point.
  /// Returns true to continue, false to stop.
  bool handle(PointNode point);
}
