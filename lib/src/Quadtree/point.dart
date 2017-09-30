part of PolygonalMapDart.Quadtree;

/// A point is a two dimensional integer coordinate.
class Point implements IPoint {
  /// Gets the distance squared between the two given points.
  static double distance2(int x1, int y1, int x2, int y2) {
    double dx = (x2 - x1).toDouble();
    double dy = (y2 - y1).toDouble();
    return dx * dx + dy * dy;
  }

  /// Gets the distance squared between the two given points.
  static double distance2Points(IPoint a, IPoint b) => distance2(a.x, a.y, b.x, b.y);

  /// Checks if the two given points are equal.
  static bool equalsPoint(IPoint a, int x, int y) {
    if (a == null) return false;
    return (a.x == x) && (a.y == y);
  }

  /// Checks if the two given points are equal.
  static bool equalPoints(IPoint a, IPoint b) {
    if (a == null) return (b == null);
    if (b == null) return false;
    return (a.x == b.x) && (a.y == b.y);
  }

  /// Finds the origin based cross product for the given points.
  static double cross(int x1, int y1, int x2, int y2) => (x1 * y2).toDouble() - (y1 * x2).toDouble();

  /// Finds the origin based cross product for the given points.
  static double crossPoints(IPoint a, IPoint b) => cross(a.x, a.y, b.x, b.y);

  /// Finds the origin based dot product for the given points.
  static double dot(int x1, int y1, int x2, int y2) => (x1 * x2).toDouble() + (y1 * y2).toDouble();

  /// Finds the origin based dot product for the given points.
  static double dotPoints(IPoint a, IPoint b) => dot(a.x, a.y, b.x, b.y);

  /// The first integer coordinate component.
  final int _x;

  /// The second integer coordinate component.
  final int _y;

  /// Any additional data that this point should contain.
  Object _data;

  /// Creates a new point.
  Point(int this._x, int this._y, [Object this._data = null]);

  /// Gets the first integer coordinate component.
  int get x => this._x;

  /// Gets the second integer coordinate component.
  int get y => this._y;

  /// Sdditional data that this point should contain.
  Object get data => this._data;
  void set data(Object data) {
    this._data = data;
  }

  /// Determines if the given object is equal to this point.
  bool equals(Object o) {
    if (o == null) return false;
    if (o is Point) return false;
    return equalPoints(this, o);
  }

  /// Gets the string for this point.
  String toString({IFormatter format: null}) {
    if (format == null)
      return "[$_x, $_y]";
    else
      return format.toPointString(this);
  }
}
