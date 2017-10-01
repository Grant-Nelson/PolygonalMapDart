part of PolygonalMapDart.Quadtree;

/// This is a point handler which collects the points into a set.
class PointCollectorHandle implements IPointHandler {
  /// The set to add new points into.
  PointNodeSet _set;

  /// The matcher to filter the collected points with.
  IPointHandler _filter;

  /// Create a new point collector.
  PointCollectorHandle(
      {PointNodeSet nodes = null, IPointHandler filter: null}) {
    this._set = (nodes == null) ? new PointNodeSet() : nodes;
    this._filter = filter;
  }

  /// The set to add new points into.
  PointNodeSet get collection => this._set;

  /// The matcher to filter the collected points with.
  IPointHandler get filter => this._filter;

  /// Handles a new point.
  bool handle(PointNode point) {
    if (this._filter != null) {
      if (!this._filter.handle(point)) return true;
    }
    this._set.nodes.add(point);
    return true;
  }
}
