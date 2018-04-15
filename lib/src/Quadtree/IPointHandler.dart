part of PolygonalMapDart.Quadtree;

/// The point handler is used to process
/// or match points with custom handlers inside for-each methods.
abstract class IPointHandler {
  /// Handles the given point.
  /// Returns true to continue, false to stop.
  bool handle(PointNode point);
}

/// The method type for handling point nodes.
typedef bool PointNodeHandler(PointNode);

/// PointHandler for calling a given function pointer for each point.
class PointMethodHandler implements IPointHandler {
  /// The handle to call for each point.
  PointNodeHandler _hndl;

  /// Creates a new point handler.
  PointMethodHandler(this._hndl);

  /// Handles the given point.
  bool handle(PointNode point) {
    return _hndl(point);
  }
}
