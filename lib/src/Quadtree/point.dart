part of PolygonalMapDart.Quadtree;

/// A point is a two dimensional integer coordinate.
class Point implements IPoint {
  /// Gets the distance squared between the two given points.
  static double distance2(IPoint a, IPoint b) {
    double dx = (b.x - a.x).toDouble();
    double dy = (b.y - a.y).toDouble();
    return dx * dx + dy * dy;
  }

  /// Checks if the two given points are equal.
  static bool equals(IPoint a, IPoint b) {
    if (a == null) return (b == null);
    if (b == null) return false;
    return (a.x == b.x) && (a.y == b.y);
  }

  /// Finds the origin based cross product for the given points.
  static double cross(IPoint a, IPoint b) =>
      (a.x * b.y).toDouble() - (a.y * b.x).toDouble();

  /// Finds the origin based dot product for the given points.
  static double dot(IPoint a, IPoint b) =>
      (a.x * b.x).toDouble() + (a.y * b.y).toDouble();

  /// The first integer coordinate component.
  final int _x;

  /// The second integer coordinate component.
  final int _y;

  /// Any additional data that this point should contain.
  Object _data;

  /// Creates a new point.
  Point(this._x, this._y, [this._data = null]);

  /// Gets the first integer coordinate component.
  int get x => _x;

  /// Gets the second integer coordinate component.
  int get y => _y;

  /// Sdditional data that this point should contain.
  Object get data => _data;
  set data(Object data) => _data = data;

  /// Gets the string for this point.
  String toString({IFormatter format: null}) {
    if (format == null) return "[$_x, $_y]";
    return format.toPointString(this);
  }
}
