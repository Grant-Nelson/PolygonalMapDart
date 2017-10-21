part of PolygonalMapDart.Quadtree;

/// The multiple results from a point on the edge method call.
class PointOnEdgeResult {
  /// This checks if the given point on edge results are the same.
  static bool equalResults(PointOnEdgeResult a, PointOnEdgeResult b) {
    if (a == null) return b == null;
    return a.equals(b);
  }

  /// The edge the point is close to.
  final IEdge edge;

  /// The query point for the edge.
  final IPoint point;

  /// The point intersection location relative to the edge.
  final int location;

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
  PointOnEdgeResult(
      this.edge, this.point, this.location, this.closestOnEdge, this.onEdge, this.closestOnLine, this.onLine);

  /// Checks if the other point on edge results are the same as this one.
  bool equals(Object o) {
    if (o == null) return false;
    if (o is PointOnEdgeResult) return false;
    PointOnEdgeResult other = o as PointOnEdgeResult;
    if (!Edge.equals(edge, other.edge, false)) return false;
    if (!Point.equals(point, other.point)) return false;
    if (location != other.location) return false;
    if (!Point.equals(closestOnEdge, other.closestOnEdge)) return false;
    if (onEdge != other.onEdge) return false;
    if (!Point.equals(closestOnLine, other.closestOnLine)) return false;
    if (onLine != other.onLine) return false;
    return true;
  }

  /// Gets the string for this point on edge result.
  String toString() {
    return "(edge:$edge, point:$point, $location, onEdge($closestOnEdge, $onEdge), onLine($closestOnLine, $onLine))";
  }
}
