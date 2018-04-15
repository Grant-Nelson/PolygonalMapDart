part of PolygonalMapDart.Quadtree;

/// The interface for geometry and quad-tree edges.
abstract class IEdge {
  /// Gets the x component of the start point of the edge.
  int get x1;

  /// Gets the y component of the start point of the edge.
  int get y1;

  /// Gets the x component of the end point of the edge.
  int get x2;

  /// Gets the y component of the end point of the edge.
  int get y2;

  /// Gets any additional data that this edge should contain.
  Object get data;

  /// Sets additional data that this edge should contain.
  void set data(Object data);

  /// Gets the start point for this edge.
  IPoint get start;

  /// Gets the end point for this edge.
  IPoint get end;

  /// Gets the change in the first component, delta X.
  int get dx;

  /// Gets the change in the second component, delta Y.
  int get dy;
}
