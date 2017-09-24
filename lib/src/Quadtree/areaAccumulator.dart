part of PolygonalMapDart.Quadtree;

/// An edge handler which can be used to accumulate a shapes area.
class AreaAccumulator implements IEdgeHandler {
  /// The currently accumulated area.
  double _area;

  /// Create a new area accumulator.
  AreaAccumulator() {
    this._area = 0.0;
  }

  /// This gets the signed area accumulated.
  /// A positive area generally wraps counter-clockwise,
  /// a negative area generally wraps clockwise.
  double get signedArea => this._area;

  /// This returns the unsigned area accumulated.
  double get area => (this._area < 0) ? -this._area : this._area;

  /// Indicates if the shape  if accumulated area is counter clockwise,
  /// Returns true if counter clockwise, false if clockwise.
  bool get ccw => this._area > 0;

  /// Adds a new edge of the shape to the accumulated area.
  /// Always returns true.
  @Override
  bool handle(EdgeNode edge) {
    this.add(edge);
    return true;
  }

  /// Adds a new edge of the shape to the accumulated area.
  void add(IEdge edge) {
    this.add(edge.x1(), edge.y1(), edge.x2(), edge.y2());
  }

  /// Adds a new edge of the shape to the accumulated area.
  void add(IPoint pnt1, IPoint pnt2) {
    this.add(pnt1.x(), pnt1.y(), pnt2.x(), pnt2.y());
  }

  /// Adds a new edge of the shape to the accumulated area.
  void add(double x1, double y1, double x2, double y2) {
    this._area += (x1 * y2 - x2 * y1) * 0.5;
  }
}
