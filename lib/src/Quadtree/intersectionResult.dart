part of PolygonalMapDart.Quadtree;

/// The result information for a two edge intersection.
class IntersectionResult implements Comparable<IntersectionResult> {
  /// Checks if the two results are the same.
  static bool equalResults(IntersectionResult a, IntersectionResult b) {
    if (a == null) return b == null;
    return a.equals(b);
  }

  /// The first edge in the intersection.
  final IEdge edgeA;

  /// The second edge in the intersection.
  final IEdge edgeB;

  /// True if the edges intersect within the edges,
  /// false if not even if infinite lines intersect.
  final bool intersects;

  /// The type of intersection.
  final int type;

  /// The intersection point or null if no intersection.
  final IPoint point;

  /// The location on the first edge that the second edge intersects it.
  final int locA;

  /// The location on the second edge that the first edge intersects it.
  final int locB;

  /// The location the second edge's start point is on the first edge.
  final PointOnEdgeResult startBOnEdgeA;

  /// The location the second edge's end point is on the first edge.
  final PointOnEdgeResult endBOnEdgeA;

  /// The location the first edge's start point is on the second edge.
  final PointOnEdgeResult startAOnEdgeB;

  /// The location the first edge's end point is on the second edge.
  final PointOnEdgeResult endAOnEdgeB;

  /// Creates a new intersection result.
  IntersectionResult(
      IEdge this.edgeA,
      IEdge this.edgeB,
      bool this.intersects,
      int this.type,
      IPoint this.point,
      int this.locA,
      int this.locB,
      PointOnEdgeResult this.startBOnEdgeA,
      PointOnEdgeResult this.endBOnEdgeA,
      PointOnEdgeResult this.startAOnEdgeB,
      PointOnEdgeResult this.endAOnEdgeB);

  /// Compares this intersection with the other intersection.
  /// Returns 1 if this intersection's edges are larger,
  /// -1 if the other intersection is larger,
  /// 0 if they have the same edges.
  int compareTo(IntersectionResult o) {
    int cmp = Edge.compare(this.edgeA, o.edgeA);
    if (cmp != 0) return cmp;
    return Edge.compare(this.edgeB, o.edgeB);
  }

  /// Checks if this intersection is the same as the other intersection.
  /// Returns true if the two intersection results are the same, false otherwise.
  bool equals(Object o) {
    if (o == null) return false;
    if (o is IntersectionResult) return false;
    IntersectionResult other = o as IntersectionResult;
    if (!Edge.equalEdges(this.edgeA, other.edgeA, false)) return false;
    if (!Edge.equalEdges(this.edgeB, other.edgeB, false)) return false;
    if (this.intersects != other.intersects) return false;
    if (this.type != other.type) return false;
    if (this.locA != other.locA) return false;
    if (this.locB != other.locB) return false;
    if (!Point.equalPoints(this.point, other.point)) return false;
    if (!PointOnEdgeResult.equalResults(
        this.startBOnEdgeA, other.startBOnEdgeA)) return false;
    if (!PointOnEdgeResult.equalResults(this.endBOnEdgeA, other.endBOnEdgeA))
      return false;
    if (!PointOnEdgeResult.equalResults(
        this.startAOnEdgeB, other.startAOnEdgeB)) return false;
    if (!PointOnEdgeResult.equalResults(this.endAOnEdgeB, other.endAOnEdgeB))
      return false;
    return true;
  }

  /// Gets the string of for this intersection result.
  String toString([String separator = ", "]) {
    return "(edgeA:$edgeA, edgeB$edgeB, " +
        (this.intersects ? "intersects" : "misses") +
        ", $type, point:$point, $locA, $locB" +
        "${separator}startBOnEdgeA:$startBOnEdgeA" +
        "${separator}endBOnEdgeA:$endBOnEdgeA" +
        "${separator}startAOnEdgeB:$startAOnEdgeB" +
        "${separator}endAOnEdgeB:$endAOnEdgeB)";
  }
}
