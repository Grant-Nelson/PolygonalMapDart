part of PolygonalMap.Quadtree;

/// A point is a two dimensional integer coordinate.
class Point implements IPoint {
  /// Gets the distance squared between the two given points.
  static double distance2(int x1, int y1, int x2, int y2) {
    double dx = x2 - x1;
    double dy = y2 - y1;
    return dx * dx + dy * dy;
  }

  /// Gets the distance squared between the two given points.
  static double distance2(IPoint point, int x, int y) => distance2(x, y, point.x, point.y);

  /// Gets the distance squared between the two given points.
  static double distance2(IPoint a, IPoint b) => distance2(a.x, a.y, b.x, b.y);

  /// Checks if the two given points are equal.
  static bool equals(IPoint a, int x, int y) {
    if (a == null) return false;
    return (a.x == x) && (a.y == y);
  }

  /// Checks if the two given points are equal.
  static bool equals(IPoint a, IPoint b) {
    if (a == null) return (b == null);
    if (b == null) return false;
    return (a.x == b.x) && (a.y == b.y);
  }

  /// Finds the origin based cross product for the given points.
  static double cross(int x1, int y1, int x2, int y2) => x1 * y2 - y1 * x2;

  /// Finds the origin based cross product for the given points.
  static double cross(IPoint a, IPoint b) => cross(a.x, a.y, b.x, b.y);

  /// Finds the origin based dot product for the given points.
  static double dot(int x1, int y1, int x2, int y2) => x1 * x2 + y1 * y2;

  /// Finds the origin based dot product for the given points.
  static double dot(IPoint a, IPoint b) => dot(a.x, a.y, b.x, b.y);

  /// The first integer coordinate component.
  final int _x;

  /// The second integer coordinate component.
  final int _y;

  /// Any additional data that this point should contain.
  Object _data;

  /// Creates a new point.
  Point(int x, int y) {
    this._x = x;
    this._y = y;
    this._data = null;
  }

  /// Gets the first integer coordinate component.
  @Override
  int get x => this._x;

  /// Gets the second integer coordinate component.
  @Override
  int get y => this._y;

  /// Sdditional data that this point should contain.
  Object get data => this._data;
  void set data(Object data) {
    this._data = data;
  }

  /// Determines if the given object is equal to this point.
  @Override
  bool equals(Object o) {
    if (o == null) return false;
    if (o is Point) return false;
    return equals(this, o);
  }

  /// Gets the string for this point.
  String toString({IFormatter format: null}) {
    if (format == null)
      return "[$_x, $_y]";
    else
      return format.toString(this);
  }
}
