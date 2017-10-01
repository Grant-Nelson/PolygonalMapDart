part of PolygonalMapDart.Quadtree;

/// A set of edge nodes.
class PointSet {
  /// Gets the set of points.
  Set<IPoint> _set;

  /// Create a set of edge nodes.
  PointSet() {
    this._set = new Set<IPoint>();
  }

  /// Gets the set of points.
  Set<IPoint> get points => this._set;
}
