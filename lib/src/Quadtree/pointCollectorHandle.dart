part of PolygonalMapDart.Quadtree;

/// This is a point handler which collects the points into a set.
class PointCollectorHandle implements IPointHandler {
  /// The set to add new points into.
  Set<PointNode> _set;

  /// The matcher to filter the collected points with.
  IPointHandler _filter;

  /// Create a new point collector.
  PointCollectorHandle(
      {Set<PointNode> nodes = null, IPointHandler filter: null}) {
    this._set = (nodes == null) ? new Set<PointNode>() : nodes;
    this._filter = filter;
  }

  /// The set to add new points into.
  Set<PointNode> get collection => this._set;

  /// The matcher to filter the collected points with.
  IPointHandler get filter => this._filter;

  /// Handles a new point.
  bool handle(PointNode point) {
    if (this._filter != null) {
      if (!this._filter.handle(point)) return true;
    }
    this._set.add(point);
    return true;
  }
}
