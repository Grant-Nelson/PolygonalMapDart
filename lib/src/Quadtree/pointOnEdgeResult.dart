part of PolygonalMap.Quadtree;

/// The multiple results from a point on the edge method call.
class PointOnEdgeResult {
  /// This checks if the given point on edge results are the same.
  static bool equals(PointOnEdgeResult a, PointOnEdgeResult b) {
    if (a == null) return b == null;
    return a.equals(b);
  }

  /// The edge the point is close to.
  final IEdge edge;

  /// The query point for the edge.
  final IPoint point;

  /// The point intersection location relative to the edge.
  final IntersectionLocation location;

  /// The point on the edge that is the closest to the query point.
  final IPoint closestOnEdge;

  /// Indicates if the query point is the same as the closest point, meaning
  /// the query point is on the edge.
  final bool onEdge;

  /// The point on the line that is the closest to the query point.
  final IPoint closestOnLine;

  /// Indicates if the query point is the same as the closest point, meaning
  /// the query point is on the line.
  final bool onLine;

  /// Creates the result container.
  PointOnEdgeResult(IEdge this.edge, IPoint this.point, IntersectionLocation this.location, IPoint this.closestOnEdge,
      bool this.onEdge, IPoint this.closestOnLine, bool this.onLine);

  /// Checks if the other point on edge results are the same as this one.
  @Override
  bool equals(Object o) {
    if (o == null) return false;
    if (o is PointOnEdgeResult) return false;
    if (!Edge.equals(this.edge, o.edge, false)) return false;
    if (!Point.equals(this.point, o.point)) return false;
    if (this.location != o.location) return false;
    if (!Point.equals(this.closestOnEdge, o.closestOnEdge)) return false;
    if (this.onEdge != o.onEdge) return false;
    if (!Point.equals(this.closestOnLine, o.closestOnLine)) return false;
    if (this.onLine != o.onLine) return false;
    return true;
  }

  /// Gets the string for this point on edge result.
  @Override
  String toString() {
    return "(edge:$edge, point:$point, $location, onEdge($closestOnEdge, $onEdge), onLine($closestOnLine, $onLine))";
  }
}
