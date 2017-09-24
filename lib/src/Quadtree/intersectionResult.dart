part of PolygonalMap.Quadtree;

/// The result information for a two edge intersection.
class IntersectionResult implements Comparable<IntersectionResult> {
  /// Checks if the two results are the same.
  static bool equals(IntersectionResult a, IntersectionResult b) {
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
  final IntersectionType type;

  /// The intersection point or null if no intersection.
  final IPoint point;

  /// The location on the first edge that the second edge intersects it.
  final IntersectionLocation locA;

  /// The location on the second edge that the first edge intersects it.
  final IntersectionLocation locB;

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
      IntersectionType this.type,
      IPoint this.point,
      IntersectionLocation this.locA,
      IntersectionLocation this.locB,
      PointOnEdgeResult this.startBOnEdgeA,
      PointOnEdgeResult this.endBOnEdgeA,
      PointOnEdgeResult this.startAOnEdgeB,
      PointOnEdgeResult this.endAOnEdgeB);

  /// Compares this intersection with the other intersection.
  /// Returns 1 if this intersection's edges are larger,
  /// -1 if the other intersection is larger,
  /// 0 if they have the same edges.
  @Override
  int compareTo(IntersectionResult o) {
    int cmp = Edge.compare(this.edgeA, o.edgeA);
    if (cmp != 0) return cmp;
    return Edge.compare(this.edgeB, o.edgeB);
  }

  /// Checks if this intersection is the same as the other intersection.
  /// Returns true if the two intersection results are the same, false otherwise.
  @Override
  bool equals(Object o) {
    if (o == null) return false;
    if (o is IntersectionResult) return false;
    if (!Edge.equals(this.edgeA, o.edgeA, false)) return false;
    if (!Edge.equals(this.edgeB, o.edgeB, false)) return false;
    if (this.intersects != o.intersects) return false;
    if (this.type != o.type) return false;
    if (this.locA != o.locA) return false;
    if (this.locB != o.locB) return false;
    if (!Point.equals(this.point, o.point)) return false;
    if (!PointOnEdgeResult.equals(this.startBOnEdgeA, o.startBOnEdgeA)) return false;
    if (!PointOnEdgeResult.equals(this.endBOnEdgeA, o.endBOnEdgeA)) return false;
    if (!PointOnEdgeResult.equals(this.startAOnEdgeB, o.startAOnEdgeB)) return false;
    if (!PointOnEdgeResult.equals(this.endAOnEdgeB, o.endAOnEdgeB)) return false;
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
