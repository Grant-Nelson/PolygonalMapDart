part of PolygonalMapDart.Quadtree;

/// This is a point handler which collects the points into a set.
class PointCollectorHandle implements IPointHandler {
  /// The set to add new points into.
  PointNodeSet _set;

  /// The matcher to filter the collected points with.
  IPointHandler _filter;

  /// Create a new point collector.
  PointCollectorHandle({IPointHandler filter: null}) {
    this._set = new PointNodeSet();
    this._filter = filter;
  }

  /// Create a new point collector.
  PointCollectorHandle(PointNodeSet set, {IPointHandler filter: null}) {
    this._set = (set == null) ? new PointNodeSet() : set;
    this._filter = filter;
  }

  /// The set to add new points into.
  PointNodeSet get collection => this._set;

  /// The matcher to filter the collected points with.
  IPointHandler get filter => this._filter;

  /// Handles a new point.
  @Override
  bool handle(PointNode point) {
    if (this._filter != null) {
      if (!this._filter.handle(point)) return true;
    }
    this._set.add(point);
    return true;
  }
}
