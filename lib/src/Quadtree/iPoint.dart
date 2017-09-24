part of PolygonalMapDart.Quadtree;

/// The interface for both the geometric point and point node.
abstract class IPoint {
  /// Gets the first integer coordinate component.
  int get x;

  /// Gets the second integer coordinate component.
  int get y;

  /// Gets any additional data that this point should contain.
  Object get data;

  /// Sets additional data that this point should contain.
  void set data(Object data);
}
